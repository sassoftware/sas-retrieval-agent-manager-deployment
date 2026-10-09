---
layout: default
title: Pre-provisioned RBAC
parent: Deployment
nav_order: 10
---

# Pre-provisioned RBAC
{: .no_toc }

1. TOC
{:toc}

---

## Overview

By default the chart creates a ServiceAccount for each component, plus the Roles and RoleBindings
those ServiceAccounts need. Some organisations do not allow an application Helm release to create
identities or grant permissions, and have a separate team provision them instead.

This page lists every ServiceAccount, Role, and RoleBinding the chart would create, so that they
can be applied separately, and explains how to point the chart at them.

Every object on this page is **namespace-scoped**. A namespace administrator can apply all of
them. The one grant that is not namespace-scoped is the OpenShift SecurityContextConstraints
binding; see [OpenShift deployment](./ocp-deployment.md#security-context-constraints).

## Inventory

### ServiceAccounts

The chart creates eight ServiceAccounts. The name column shows the default; each is configurable
through the listed value, except where noted.

| ServiceAccount | Values key | Used by |
|----------------|------------|---------|
| `<name>-api` | `api.serviceAccount.name` | API deployment |
| `<name>-api-spawn` | `api.spawn.serviceAccount.name` | The agent, evaluation, vectorization, embedding, and MCP tool workloads the API creates at run time |
| `<name>-app` | `ui.serviceAccount.name` | UI deployment |
| `<name>-keycloak` | `iam.keycloak.serviceAccount.name` | Keycloak deployment |
| `<name>-keycloak-realm-update` | *none, see below* | Keycloak realm update job |
| `<name>-postgrest` | `db.rest.serviceAccount.name` | PostgREST deployment and PostgREST role update job |
| `<name>-db-init` | `db.init.serviceAccount.name` | Database initialization job |
| `<name>-db-migration` | `db.migration.serviceAccount.name` | Database migration job and the LLM and embedding model hydration jobs |

`<name>` is your `name` value, or `<release>-sas-retrieval-agent-manager` when `name` is unset.

> [!IMPORTANT]
> `<name>-keycloak-realm-update` has no values key of its own. It is derived by appending
> `-realm-update` to `iam.keycloak.serviceAccount.name`, and it is created only when
> `iam.keycloak.serviceAccount.create` is `true`. It is the single easiest ServiceAccount to miss,
> and the realm update job is a `post-install,post-upgrade` hook, so missing it fails the install
> rather than degrading it.

> [!NOTE]
> `api.spawn.serviceAccount.name` is not used by any pod in the Helm release. It is passed to the
> API, which assigns it to the workloads it creates later. A missing `-api-spawn` ServiceAccount
> therefore produces a working install that fails the first time a user starts an agent.

### Roles and RoleBindings

Only four components need Kubernetes API access. Each RoleBinding binds the matching Role to the
matching ServiceAccount, and all names are identical to the ServiceAccount name.

| Role | Grants |
|------|--------|
| `<name>-api` | Manage `jobs`, `cronjobs`, `deployments`, `services`, `configmaps`, `secrets`, and `horizontalpodautoscalers`; read `pods` and `pods/log`. This is what lets the API create and tear down spawned workloads. |
| `<name>-db-init` | `get` and `patch` on the single secret `<name>-admin-db-credentials`, to write back generated credentials. |
| `<name>-postgrest` | `get` and `list` on the single secret `<name>-keycloak-certs`, to validate JWTs. |
| `<name>-keycloak-realm-update` | Nothing. `rules: []`. The job talks to the Keycloak admin API over HTTP. |

The remaining ServiceAccounts, `-api-spawn`, `-app`, `-keycloak`, and `-db-migration`, need no
Role at all.

> [!WARNING]
> The `-api` and `-db-init` Roles and RoleBindings are rendered **only when the matching
> `serviceAccount.create` is `true`**. Setting `create: false` therefore removes the API's
> permissions along with its ServiceAccount, and nothing warns you. The API then starts
> normally and fails only when it tries to create a workload. If you set `create: false`, you
> must apply these Roles and RoleBindings yourself.

### Objects you must not pre-create

`<name>-db-migration-cleanup-sa` and its Role and RoleBinding are Helm `pre-upgrade` hook objects.
Helm creates them before an upgrade and deletes them when the hook succeeds, regardless of any
`serviceAccount.create` value. Leave them to Helm. Pre-creating them makes the upgrade fail,
because Helm will not adopt objects it does not own.

The `oauth2-proxy` ServiceAccount is vestigial. OAuth2 Proxy runs as a sidecar under its parent
pod's ServiceAccount, so nothing references it. You do not need to create it.

## Procedure

**Step 1. Apply the RBAC objects.**

Use the
[example manifest](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/rbac/preprovisioned-rbac.yaml).
Replace the namespace and the `retrieval-agent-manager` prefix with your own values, then apply:

```bash
oc apply -f preprovisioned-rbac.yaml    # or kubectl apply
```

To generate the objects for your exact values rather than using the reference copy, render the
chart with ServiceAccount creation forced on and keep only the RBAC kinds:

```bash
helm template <release> <chart> -f values.yaml --namespace <namespace> \
  --set api.serviceAccount.create=true \
  --set api.spawn.serviceAccount.create=true \
  --set ui.serviceAccount.create=true \
  --set iam.keycloak.serviceAccount.create=true \
  --set db.rest.serviceAccount.create=true \
  --set db.init.serviceAccount.create=true \
  --set db.migration.serviceAccount.create=true \
| yq 'select(.kind == "ServiceAccount" or .kind == "Role" or .kind == "RoleBinding")
      | select(.metadata.annotations["helm.sh/hook"] == null)'
```

The `helm.sh/hook` filter drops the cleanup objects described above.

**Step 2. Point the chart at them.**

Set `create: false` and an explicit `name` for every component. The names must match the objects
you applied exactly; the chart does not verify that a referenced ServiceAccount exists.

```yaml
api:
  serviceAccount:
    create: false
    name: retrieval-agent-manager-api
  spawn:
    serviceAccount:
      create: false
      name: retrieval-agent-manager-api-spawn
ui:
  serviceAccount:
    create: false
    name: retrieval-agent-manager-app
iam:
  keycloak:
    serviceAccount:
      create: false
      # The realm update job uses this name plus "-realm-update".
      name: retrieval-agent-manager-keycloak
db:
  rest:
    serviceAccount:
      create: false
      name: retrieval-agent-manager-postgrest
  init:
    serviceAccount:
      create: false
      name: retrieval-agent-manager-db-init
  migration:
    serviceAccount:
      create: false
      name: retrieval-agent-manager-db-migration
```

> [!WARNING]
> Do not leave `name` empty while `create` is `false`. The chart falls back to the namespace
> `default` ServiceAccount, which has no RoleBindings and, on OpenShift, would need the
> SecurityContextConstraints grant. The failure is silent until a component needs a permission.

**Step 3. On OpenShift, grant the SCC.**

The SCC grant is separate because a SecurityContextConstraints object is cluster-scoped. Follow
[OpenShift deployment](./ocp-deployment.md#security-context-constraints). The chart's SCC grant
covers all of the ServiceAccount names above whether or not the chart created them, so no extra
step is needed when `platform: openshift`.

**Step 4. Verify before you install.**

```bash
NS=retagentmgr
PREFIX=retrieval-agent-manager

for sa in api api-spawn app keycloak keycloak-realm-update postgrest db-init db-migration; do
  oc get serviceaccount "$PREFIX-$sa" -n "$NS" >/dev/null 2>&1 \
    && echo "ok   $PREFIX-$sa" \
    || echo "MISSING  $PREFIX-$sa"
done

# The API must be able to create the workloads it spawns.
oc auth can-i create deployments \
  --as="system:serviceaccount:$NS:$PREFIX-api" -n "$NS"
oc auth can-i create jobs \
  --as="system:serviceaccount:$NS:$PREFIX-api" -n "$NS"
```

Both `can-i` checks must print `yes`. If they print `no`, the `-api` Role or RoleBinding is
missing; see the warning in [Roles and RoleBindings](#roles-and-rolebindings).

## Troubleshooting

| Symptom | Cause |
|---------|-------|
| `pods "<name>-keycloak-realm-update-" is forbidden: unable to validate against any security context constraint` | On OpenShift, the realm update ServiceAccount has no SCC grant. See [OpenShift deployment](./ocp-deployment.md#security-context-constraints). |
| Install succeeds, but starting an agent fails with a `403` from the Kubernetes API | The `-api` Role or RoleBinding is missing, or `-api-spawn` does not exist. |
| Database initialization job fails writing credentials | The `-db-init` Role or RoleBinding is missing. |
| PostgREST returns `401` for every request | The `-postgrest` Role is missing, so PostgREST cannot read `<name>-keycloak-certs`. |
| Upgrade fails with `invalid ownership metadata` on `<name>-db-migration-cleanup-*` | Those objects were pre-created. Delete them and let Helm manage them. |
