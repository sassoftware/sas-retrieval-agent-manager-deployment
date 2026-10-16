{{/*
Expand the name of the chart.
*/}}
{{- define "retrieval-agent-manager.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "retrieval-agent-manager.fullname" -}}
{{- if .Values.name }}
{{- .Values.name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "retrieval-agent-manager.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
connection-validation is to verify that argo is pulling from the correct branch
*/}}
{{- define "retrieval-agent-manager.labels" -}}
helm.sh/chart: {{ include "retrieval-agent-manager.chart" . }}
{{ include "retrieval-agent-manager.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/connection-validation: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "retrieval-agent-manager.selectorLabels" -}}
app.kubernetes.io/name: {{ include "retrieval-agent-manager.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Render a pod security context, stripping runAsUser/runAsGroup/runAsNonRoot on OpenShift
so the SCC assigns them from the namespace UID range automatically.
fsGroup is retained so Kubernetes triggers volume ownership chown on EBS/PVC mounts.
Usage: {{ include "ram.podSecurityContext" (list .Values.X.podSecurityContext .Values.platform) | nindent 8 }}
*/}}
{{- define "ram.podSecurityContext" -}}
{{- $sc := index . 0 -}}
{{- $platform := index . 1 -}}
{{- if eq $platform "openshift" -}}
{{- omit $sc "runAsUser" "runAsGroup" "runAsNonRoot" | toYaml -}}
{{- else -}}
{{- $sc | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
Render a pod security context for a pod that must be admitted WITHOUT the chart's own SCC.

`pre-upgrade` hook pods need this. The SecurityContextConstraints and its ClusterRoleBinding are
ordinary resources, not hooks, so during a pre-upgrade hook the cluster still has the *previous*
release's copy of them. On the first upgrade to a chart version that grants a new ServiceAccount,
that grant is not in effect yet. A pre-upgrade hook pod therefore cannot rely on the chart's SCC
no matter which ServiceAccount it runs under, and must satisfy whatever SCC the namespace already
provides, normally `restricted-v2`.

So this drops `fsGroup` on OpenShift as well. `restricted-v2` uses a `MustRunAs` fsGroup strategy
validated against the namespace's pre-allocated range, and rejects a hardcoded value such as
10001. Only use this for pods with no persistent volumes: `ram.podSecurityContext` keeps `fsGroup`
precisely so Kubernetes chowns EBS/PVC mounts, and that is lost here.

Usage: {{ include "ram.hookPodSecurityContext" (list .Values.X.podSecurityContext .Values.platform) | nindent 8 }}
*/}}
{{- define "ram.hookPodSecurityContext" -}}
{{- $sc := index . 0 -}}
{{- $platform := index . 1 -}}
{{- if eq $platform "openshift" -}}
{{- omit $sc "runAsUser" "runAsGroup" "runAsNonRoot" "fsGroup" | toYaml -}}
{{- else -}}
{{- $sc | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
Render a container security context, stripping runAsUser/runAsGroup on OpenShift.
Usage: {{ include "ram.securityContext" (list .Values.X.securityContext .Values.platform) | nindent 12 }}
*/}}
{{- define "ram.securityContext" -}}
{{- $sc := index . 0 -}}
{{- $platform := index . 1 -}}
{{- if eq $platform "openshift" -}}
{{- omit $sc "runAsUser" "runAsGroup" "runAsNonRoot" | toYaml -}}
{{- else -}}
{{- $sc | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
The name of the SecurityContextConstraints this release's pods run under.

Defaults to "<fullname>-scc", the SCC the chart creates. Override `security.scc.name` to point the
binding at an SCC an administrator applied out of band, which is the only option on clusters where
application installers may not create cluster-scoped objects.
*/}}
{{- define "ram.sccName" -}}
{{- .Values.security.scc.name | default (printf "%s-scc" (include "retrieval-agent-manager.fullname" .)) -}}
{{- end -}}

{{/*
Whether this release creates the SecurityContextConstraints and its backing ClusterRole.

Both are CLUSTER-SCOPED, so creating them requires cluster-admin. Returns "true"/"" (empty is
false in Helm's `if`).

`security.scc.create` wins when set to a real boolean. When left null it falls back to the
platform: true on OpenShift, false everywhere else -- which is the pre-existing behaviour, so an
OpenShift values file that does not mention `security.scc` keeps working unchanged.

Set it to false when an administrator applies the SCC and ClusterRole separately; pair that with
`security.scc.binding: namespace` so the release still grants itself the SCC, using a namespaced
RoleBinding. See examples/openshift/scc-namespace-scoped.yaml in the deployment repository.
*/}}
{{- define "ram.sccCreate" -}}
{{- if not (kindIs "invalid" .Values.security.scc.create) -}}
{{- if .Values.security.scc.create -}}true{{- end -}}
{{- else if eq .Values.platform "openshift" -}}
true
{{- end -}}
{{- end -}}

{{/*
How this release grants the SCC to its ServiceAccounts: "cluster", "namespace" or "none".

  cluster   - ClusterRoleBinding. Cluster-scoped, needs cluster-admin. The default on OpenShift.
  namespace - RoleBinding in the release namespace, referencing the ClusterRole by name. Grants the
              SCC only to the subjects named in it, and only here. Use when the cluster forbids
              ClusterRoleBindings for application workloads. The ClusterRole it points at must
              exist -- see the warning in scc-rolebinding.yaml.
  none      - The chart grants nothing; an administrator binds the SCC out of band.

`security.scc.binding` wins when set. When empty it follows the platform: "cluster" on OpenShift,
"none" everywhere else.
*/}}
{{- define "ram.sccBinding" -}}
{{- if .Values.security.scc.binding -}}
{{- .Values.security.scc.binding -}}
{{- else if eq .Values.platform "openshift" -}}
cluster
{{- else -}}
none
{{- end -}}
{{- end -}}

{{/*
The ServiceAccount names of every pod this chart runs, as a newline-separated list.

Single source of truth for the OpenShift SCC grant. templates/security/scc/scc.yaml and
templates/security/scc/scc-rolebinding.yaml both consume this, so the SCC's `users` list and
the ClusterRoleBinding's `subjects` list cannot drift apart.

Deliberately NOT gated on `serviceAccount.create`. Whether the chart creates a ServiceAccount
or the cluster administrator pre-creates it out of band, the pods still run under that name and
still need the SCC. The *.serviceAccountName helpers already resolve to the effective name in
both cases.

One pod is deliberately absent: the `pre-upgrade` upgrade-validation hook runs under the
namespace `default` ServiceAccount. Granting the SCC to `default` would hand it to every
workload in the namespace, and would not work anyway, because this SCC is an ordinary resource
and a pre-upgrade hook sees the previous release's copy of it. That pod is admitted under the
namespace's existing SCC instead; see "ram.hookPodSecurityContext".

Usage: {{ include "ram.sccServiceAccountNames" . | splitList "\n" }}
*/}}
{{- define "ram.sccServiceAccountNames" -}}
{{- $names := list -}}
{{- $names = append $names (include "api.serviceAccountName" .) -}}
{{- $names = append $names (include "api.spawn.serviceAccountName" .) -}}
{{- $names = append $names (include "ui.serviceAccountName" .) -}}
{{- $names = append $names (include "keycloak.serviceAccountName" .) -}}
{{- $names = append $names (printf "%s-realm-update" (include "keycloak.serviceAccountName" .)) -}}
{{- $names = append $names (include "postgrest.serviceAccountName" .) -}}
{{- $names = append $names (include "db-initialization.serviceAccountName" .) -}}
{{- $names = append $names (include "db-migration.serviceAccountName" .) -}}
{{- $names = append $names (include "upgrade.cleanupServiceAccountName" .) -}}
{{- $names | uniq | sortAlpha | join "\n" -}}
{{- end -}}
