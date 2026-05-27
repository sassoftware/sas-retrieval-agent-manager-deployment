#!/usr/bin/env bash
# =============================================================================
# bootstrap-gpg.sh
#
# Creates the three GPG-related K8s resources that Helm templates reference
# but do not own:
#   - <gpg-fullname>-passphrase        (Secret)
#   - <gpg-fullname>-private-key       (Secret)
#   - <gpg-fullname>-public-key        (ConfigMap)
#
# Resource naming mirrors the gpg.fullname Helm helper exactly:
#   default:              retrieval-agent-manager-gpg-{passphrase,private-key,public-key}
#   --name-override foo:  foo-gpg-{passphrase,private-key,public-key}
#
# The same --name-override value must be set in values.yaml:
#   security.gpg.nameOverride: foo
#
# Idempotent: if all three already exist, exits 0 without touching anything.
# Partial state (some exist, some don't) is flagged as an error — operator
# must resolve manually before re-running.
#
# Intended to be run as a Docker container — all dependencies (gpg, kubectl)
# are bundled in the image. A kubeconfig is mounted at runtime.
# No interactive input required -- a passphrase is generated automatically
# and printed once on completion. Save it somewhere safe (e.g. Azure Key Vault).
#
# Usage (Docker):
#   Linux/macOS:
#     docker run --rm -it \
#       -v ~/.kube:/root/.kube:ro \
#       ram-bootstrap-gpg \
#       --release <release> --namespace <namespace> [options]
#
#   Windows (PowerShell):
#     docker run --rm -it `
#       -v "$env:USERPROFILE\.kube:/root/.kube:ro" `
#       ram-bootstrap-gpg `
#       --release <release> --namespace <namespace> [options]
#
# Options:
#   --release       -r   Helm release name
#   --namespace     -n   Kubernetes namespace
#   --name-override      Override the base name used for resource naming
#                        Mirrors security.gpg.nameOverride in values.yaml
#                        Default: retrieval-agent-manager
#   --key-name           GPG uid real name     (default: "RAM Secrets")
#   --key-email          GPG uid email         (default: "ram@sas.com")
#   --key-comment        GPG uid comment       (default: "RAM GPG Key")
#   --key-length         RSA key length        (default: 4096)
#   --key-expire         Key expiry            (default: 0 = never)
#   --help          -h   Show this message
# =============================================================================

set -euo pipefail

# ── helpers ──────────────────────────────────────────────────────────────────

log()  { echo "[$(date -u +%H:%M:%S)] $*"; }
ok()   { echo "[$(date -u +%H:%M:%S)] ✅ $*"; }
warn() { echo "[$(date -u +%H:%M:%S)] ⚠️  $*"; }
die()  { echo "[$(date -u +%H:%M:%S)] ❌ $*" >&2; exit 1; }

usage() {
  sed -n '/^# Usage:/,/^# ====/p' "$0" | sed 's/^# \?//'
  exit 0
}

# ── argument parsing ──────────────────────────────────────────────────────────

RELEASE="retrieval-agent-manager"
NAMESPACE="retagentmgr"
NAME_OVERRIDE=""
KEY_NAME="RAM Secrets"
KEY_EMAIL="ram@sas.com"
KEY_COMMENT="RAM GPG Key"
KEY_LENGTH=4096
KEY_EXPIRE="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --release|-r)      RELEASE="$2";       shift 2 ;;
    --namespace|-n)    NAMESPACE="$2";     shift 2 ;;
    --name-override)   NAME_OVERRIDE="$2"; shift 2 ;;
    --key-name)        KEY_NAME="$2";      shift 2 ;;
    --key-email)       KEY_EMAIL="$2";     shift 2 ;;
    --key-comment)     KEY_COMMENT="$2";   shift 2 ;;
    --key-length)      KEY_LENGTH="$2";    shift 2 ;;
    --key-expire)      KEY_EXPIRE="$2";    shift 2 ;;
    --help|-h)         usage ;;
    *) die "Unknown argument: $1" ;;
  esac
done

# ── derived resource names (mirrors gpg.fullname Helm helper) ─────────────────
#
# gpg.fullname = printf "%s-gpg" (retrieval-agent-manager.fullname)
#
# security.gpg.nameOverride in values.yaml lets you replace the
# "retrieval-agent-manager" prefix with a shorter name, producing:
#   no override:         retrieval-agent-manager-gpg-{passphrase,private-key,public-key}
#   nameOverride: foo:   foo-gpg-{passphrase,private-key,public-key}
#
# Pass --name-override here to match whatever security.gpg.nameOverride
# is set to in your values.yaml.

DEFAULT_BASE="retrieval-agent-manager"
BASE_NAME="${NAME_OVERRIDE:-${DEFAULT_BASE}}"
GPG_FULLNAME="${BASE_NAME}-gpg"

SECRET_PASSPHRASE="${GPG_FULLNAME}-passphrase"
SECRET_PRIVATE_KEY="${GPG_FULLNAME}-private-key"
CM_PUBLIC_KEY="${GPG_FULLNAME}-public-key"

# ── dependency checks ─────────────────────────────────────────────────────────
# When run via Docker these are always present. Guard here catches direct
# invocation outside the container.

for cmd in kubectl gpg; do
  command -v "${cmd}" >/dev/null 2>&1 || die "'${cmd}' not found. Run this script via Docker — see usage in header."
done

# Kubeconfig: kubectl will use /root/.kube/config (mounted at docker run time).
# Verify it's actually reachable before doing anything.
kubectl cluster-info >/dev/null 2>&1   || die "Cannot reach the cluster. Check that your kubeconfig is mounted: -v ~/.kube:/root/.kube:ro"

# Make sure namespace exists
if kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1; then
  log "Namespace '${NAMESPACE}' already exists."
else
  log "Namespace '${NAMESPACE}' not found — creating…"
  kubectl create namespace "${NAMESPACE}"
  ok "Namespace '${NAMESPACE}' created."
fi

# ── idempotency check ─────────────────────────────────────────────────────────

log "Checking for existing resources in namespace '${NAMESPACE}'…"

exists_passphrase=false
exists_private=false
exists_public=false

kubectl get secret     "${SECRET_PASSPHRASE}" -n "${NAMESPACE}" >/dev/null 2>&1 && exists_passphrase=true
kubectl get secret     "${SECRET_PRIVATE_KEY}" -n "${NAMESPACE}" >/dev/null 2>&1 && exists_private=true
kubectl get configmap  "${CM_PUBLIC_KEY}"      -n "${NAMESPACE}" >/dev/null 2>&1 && exists_public=true

if [[ "${exists_passphrase}" == "true" && "${exists_private}" == "true" && "${exists_public}" == "true" ]]; then
  ok "All three resources already exist — nothing to do."
  exit 0
fi

# Partial state is ambiguous — don't proceed
partial=false
[[ "${exists_passphrase}" == "true" ]] && partial=true
[[ "${exists_private}"    == "true" ]] && partial=true
[[ "${exists_public}"     == "true" ]] && partial=true

if [[ "${partial}" == "true" ]]; then
  warn "Partial state detected:"
  [[ "${exists_passphrase}" == "true" ]] && warn "  EXISTS:  Secret '${SECRET_PASSPHRASE}'"    || warn "  MISSING: Secret '${SECRET_PASSPHRASE}'"
  [[ "${exists_private}"    == "true" ]] && warn "  EXISTS:  Secret '${SECRET_PRIVATE_KEY}'"   || warn "  MISSING: Secret '${SECRET_PRIVATE_KEY}'"
  [[ "${exists_public}"     == "true" ]] && warn "  EXISTS:  ConfigMap '${CM_PUBLIC_KEY}'"     || warn "  MISSING: ConfigMap '${CM_PUBLIC_KEY}'"
  die "Resolve partial state manually, then re-run."
fi

log "No existing resources found — proceeding with bootstrap."

# ── passphrase generation ─────────────────────────────────────────────────────
# Generate a cryptographically random 32-byte passphrase (base64-encoded, 44 chars).
# It is stored in the K8s Secret and printed once at the end — save it somewhere safe.

GPG_PASSPHRASE="$(head -c 32 /dev/urandom | base64 | tr -d '\n')"
[[ -n "${GPG_PASSPHRASE}" ]] || die "Failed to generate passphrase."
log "Passphrase generated (will be shown on completion)."

# ── working directory (cleaned up on exit) ────────────────────────────────────

WORK_DIR="$(mktemp -d)"
GNUPGHOME="$(mktemp -d)"
export GNUPGHOME
chmod 700 "${GNUPGHOME}"
trap 'rm -rf "${WORK_DIR}" "${GNUPGHOME}"' EXIT

PUBLIC_KEY_PATH="${WORK_DIR}/public.key"
PRIVATE_KEY_PATH="${WORK_DIR}/private.key"

# ── GPG key generation ────────────────────────────────────────────────────────

log "Generating ${KEY_LENGTH}-bit RSA GPG key pair…"

cat > "${WORK_DIR}/gen-key-script" <<EOF
%no-protection
%echo Generating GPG key
Key-Type: RSA
Key-Length: ${KEY_LENGTH}
Subkey-Type: RSA
Name-Real: ${KEY_NAME}
Name-Comment: ${KEY_COMMENT}
Name-Email: ${KEY_EMAIL}
Expire-Date: ${KEY_EXPIRE}
%commit
%echo done
EOF

gpg --batch --generate-key "${WORK_DIR}/gen-key-script"
rm "${WORK_DIR}/gen-key-script"

KEY_FPR="$(gpg --list-keys --with-colons "${KEY_EMAIL}" \
  | awk -F: '/^fpr:/ {print $10; exit}')"
[[ -n "${KEY_FPR}" ]] || die "Could not determine GPG fingerprint."
ok "Key generated. Fingerprint: ${KEY_FPR}"

gpg --armor --export "${KEY_FPR}"             > "${PUBLIC_KEY_PATH}"
gpg --armor --export-secret-keys "${KEY_FPR}" > "${PRIVATE_KEY_PATH}"

# ── save keys locally ────────────────────────────────────────────────────────
# /output is mounted from the host at docker run time.
# Linux/macOS:  -v "$(pwd)/output:/output"
# Windows PS:   -v "${PWD}/output:/output"
# Falls back gracefully if not mounted — keys are still applied to the cluster.

LOCAL_OUTPUT="/output"
if [[ -d "${LOCAL_OUTPUT}" ]]; then
  cp "${PUBLIC_KEY_PATH}"  "${LOCAL_OUTPUT}/${GPG_FULLNAME}-public.key"
  cp "${PRIVATE_KEY_PATH}" "${LOCAL_OUTPUT}/${GPG_FULLNAME}-private.key"
  printf '%s' "${GPG_PASSPHRASE}" > "${LOCAL_OUTPUT}/${GPG_FULLNAME}-passphrase.txt"
  ok "Keys saved to ${LOCAL_OUTPUT}/:"
  ok "  ${GPG_FULLNAME}-public.key"
  ok "  ${GPG_FULLNAME}-private.key"
  ok "  ${GPG_FULLNAME}-passphrase.txt"
  warn "These files are sensitive — store them somewhere safe and restrict access."
else
  warn "/output not mounted — skipping local save."
  warn "Add -v \"\$(pwd)/output:/output\" (Linux) or -v \"\${PWD}/output:/output\" (PowerShell) to save locally."
fi

# ── create K8s resources ──────────────────────────────────────────────────────
# Resources are created with Helm ownership labels/annotations so that
# helm install does not reject them as externally-owned resources.

log "Creating Secret '${SECRET_PASSPHRASE}'…"
kubectl create secret generic "${SECRET_PASSPHRASE}" \
  -n "${NAMESPACE}" \
  --from-literal=passphrase="${GPG_PASSPHRASE}" \
  --dry-run=client -o yaml \
| kubectl apply -n "${NAMESPACE}" -f -
ok "Secret '${SECRET_PASSPHRASE}' created."

log "Creating Secret '${SECRET_PRIVATE_KEY}'…"
kubectl create secret generic "${SECRET_PRIVATE_KEY}" \
  -n "${NAMESPACE}" \
  --from-file=privateKey="${PRIVATE_KEY_PATH}" \
  --dry-run=client -o yaml \
| kubectl apply -n "${NAMESPACE}" -f -
ok "Secret '${SECRET_PRIVATE_KEY}' created."

log "Creating ConfigMap '${CM_PUBLIC_KEY}'…"
kubectl create configmap "${CM_PUBLIC_KEY}" \
  -n "${NAMESPACE}" \
  --from-file=public="${PUBLIC_KEY_PATH}" \
  --dry-run=client -o yaml \
| kubectl apply -n "${NAMESPACE}" -f -
ok "ConfigMap '${CM_PUBLIC_KEY}' created."

echo ""
echo "========================================================"
ok "Bootstrap complete."
echo ""
echo "  ⚠️  Save this passphrase now — it will not be shown again:"
echo ""
echo "  GPG Passphrase: ${GPG_PASSPHRASE}"
echo ""
echo "  It is stored in Secret '${SECRET_PASSPHRASE}'"
echo "  under key 'passphrase' in namespace '${NAMESPACE}'."
if [[ -d "/output" ]]; then
  echo ""
  echo "  Local copies written to your output/ directory."
fi
echo "========================================================"
echo ""
ok "You can now install SAS Retrieval Agent Manager following the documentation."
if [[ -n "${NAME_OVERRIDE}" ]]; then
  echo ""
  log "Set the following in your values.yaml to match these resource names:"
  echo ""
  echo "  security:"
  echo "    gpg:"
  echo "      nameOverride: \"${NAME_OVERRIDE}\""
  echo ""
fi