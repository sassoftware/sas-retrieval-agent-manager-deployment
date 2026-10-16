#!/usr/bin/env bash

set -euo pipefail

: "${KUBECONFIG:?KUBECONFIG is required}"
: "${VIYA_URL:?VIYA_URL is required}"
: "${SASBOOT_PASSWORD:?SASBOOT_PASSWORD is required}"

namespace="${PROVISION_NAMESPACE:-${VIYA_NAMESPACE:-${RAM_NAMESPACE:-retagentmgr}}}"
viya_namespace="${VIYA_NAMESPACE:-$namespace}"
job_name="viya-home-directory-provisioner"
secret_name="${job_name}-credentials"
configmap_name="${job_name}-script"
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
script_path="$script_dir/create_home_directories_vk.sh"
kubectl_args=()
if [[ -n "${KUBE_CONTEXT:-}" ]]; then
  kubectl_args+=(--context "$KUBE_CONTEXT")
fi

kubectl_cmd() {
  kubectl "${kubectl_args[@]}" "$@"
}

cleanup() {
  kubectl_cmd delete job "$job_name" --namespace "$namespace" --ignore-not-found >/dev/null 2>&1 || true
  kubectl_cmd delete secret "$secret_name" --namespace "$namespace" --ignore-not-found >/dev/null 2>&1 || true
  kubectl_cmd delete configmap "$configmap_name" --namespace "$namespace" --ignore-not-found >/dev/null 2>&1 || true
}
trap cleanup EXIT

if [[ ! -f "$script_path" ]]; then
  printf 'The home-directory script was not found: %s\n' "$script_path" >&2
  exit 1
fi

if nfs_json=$(kubectl_cmd get pods --namespace "$viya_namespace" --output json | jq -ce '
  [.items[].spec.volumes[]? | select(.nfs.server? and .nfs.path? and (.nfs.path | endswith("/homes"))) | .nfs]
  | unique
  | if length == 1 then .[0]
    elif length == 0 then error("no inline NFS volume with a /homes path was found")
    else error("multiple inline NFS volumes with a /homes path were found")
    end
'); then
  printf 'Discovered the Viya home export from an inline NFS volume.\n'
else
  nfs_json=$(kubectl_cmd get pv --output json | jq -ce '
    [.items[] | select(.spec.nfs.server? and .spec.nfs.path? and (.spec.nfs.path | endswith("/homes"))) | .spec.nfs]
    | unique
    | if length == 1 then .[0]
      elif length == 0 then error("no NFS home export was found in Viya pods or persistent volumes")
      else error("multiple NFS home exports were found in persistent volumes")
      end
  ')
  printf 'Discovered the Viya home export from a persistent volume.\n'
fi
nfs_server=$(jq -r '.server' <<< "$nfs_json")
nfs_path=$(jq -r '.path' <<< "$nfs_json")

if [[ -z "$nfs_server" || "$nfs_server" == null || "$nfs_path" != /*/homes ]]; then
  printf 'The discovered NFS home export is invalid.\n' >&2
  exit 1
fi

kubectl_cmd create configmap "$configmap_name" \
  --namespace "$namespace" \
  --from-file=create_home_directories_vk.sh="$script_path" \
  --dry-run=client --output yaml | kubectl_cmd apply --filename - >/dev/null
kubectl_cmd create secret generic "$secret_name" \
  --namespace "$namespace" \
  --from-literal=password="$SASBOOT_PASSWORD" \
  --dry-run=client --output yaml | kubectl_cmd apply --filename - >/dev/null

jq -n \
  --arg namespace "$namespace" \
  --arg job_name "$job_name" \
  --arg secret_name "$secret_name" \
  --arg configmap_name "$configmap_name" \
  --arg viya_url "$VIYA_URL" \
  --arg viya_user "${VIYA_USER:-sasboot}" \
  --arg nfs_server "$nfs_server" \
  --arg nfs_path "$nfs_path" \
  '{
    apiVersion: "batch/v1",
    kind: "Job",
    metadata: {name: $job_name, namespace: $namespace},
    spec: {
      backoffLimit: 0,
      ttlSecondsAfterFinished: 3600,
      template: {
        metadata: {labels: {app: $job_name}},
        spec: {
          restartPolicy: "Never",
          automountServiceAccountToken: false,
          securityContext: {runAsUser: 0, runAsGroup: 0, seccompProfile: {type: "RuntimeDefault"}},
          containers: [{
            name: "provision",
            image: "alpine:3.20",
            securityContext: {allowPrivilegeEscalation: true},
            env: [
              {name: "VIYA_URL", value: $viya_url},
              {name: "VIYA_USER", value: $viya_user},
              {name: "VIYA_PASSWORD", valueFrom: {secretKeyRef: {name: $secret_name, key: "password"}}}
            ],
            command: ["/bin/sh", "-c"],
            args: [
                      "apk add --no-cache bash coreutils curl jq >/dev/null && bash /opt/script/create_home_directories_vk.sh --directory /export/viya/homes --baseurl \"\u0024VIYA_URL\" --user \"\u0024VIYA_USER\" --password \"\u0024VIYA_PASSWORD\""
            ],
            volumeMounts: [
              {name: "homes", mountPath: "/export/viya/homes", readOnly: false},
              {name: "script", mountPath: "/opt/script", readOnly: true}
            ]
          }],
          volumes: [
            {name: "homes", nfs: {server: $nfs_server, path: $nfs_path, readOnly: false}},
            {name: "script", configMap: {name: $configmap_name, defaultMode: 365}}
          ]
        }
      }
    }
  }' | kubectl_cmd apply --filename - >/dev/null

kubectl_cmd wait --for=condition=complete "job/$job_name" \
  --namespace "$namespace" --timeout=15m
