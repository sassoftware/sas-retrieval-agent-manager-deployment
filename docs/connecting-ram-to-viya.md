---
layout: default
title: Connecting RAM to Viya
parent: Deployment
nav_order: 10
---

# Connecting RAM to Viya
{: .no_toc }

1. TOC
{:toc}

---

Use this guide after you install SAS Retrieval Agent Manager (RAM). The helper connects RAM sign-in to
SAS Viya single sign-on (SSO). It also creates two Model Context Protocol (MCP) tools servers.

The helper uses your current Kubernetes context. It does not require an Azure subscription ID,
resource group, cluster name, or hosting boundary.

## What the helper configures

The helper performs these operations in order:

1. Set SAS Logon `issuer.uri` to the RAM-facing SAS Logon URL.
2. Restart SAS Logon and verify its token issuer.
3. Configure Viya SSO for RAM.
4. Create or update the Viya OAuth client with the `SASAdministrators` authority.
5. Configure the RAM Keycloak identity provider, hardcoded group mappers, and token exchange.
6. Add the Viya identity-provider hint to the RAM sign-in redirect.
7. Restart and verify the RAM API and app deployments.
8. Create missing Viya user home directories.
9. Create an OAuth client-credentials MCP tools server.
10. Create a user-token MCP tools server.
11. Add RAM to the Viya application menu.

The helper creates temporary Kubernetes resources to create user home directories. The Job runs as
user ID 0. It mounts the Viya NFS home export with write access. Confirm that this change is allowed
in your environment before you continue.

## MCP authentication methods

The OAuth-based tools server is named `sas-mcp-tools`. It uses the `ram-app` Viya OAuth client and
the `client_credentials` grant. It accesses Viya as that client.

The user-token tools server is named `user-authenticated sas-mcp-tools`. It uses the RAM identity
broker and the `viya-oidc` identity provider. It accesses Viya with the signed-in user's Viya token.
This server requires successful Viya sign-in and Keycloak token exchange.

Both tools servers use `ALLOW_RAW_BEARER=true`. Review this setting against your security policy.

## Requirements

Complete these requirements before you run the helper:

- Install and verify RAM.
- Install SAS Viya in the Kubernetes cluster.
- Confirm the current Kubernetes context.
- Confirm that the Viya and RAM URLs use HTTPS and are accessible from your computer.
- Confirm that the current Kubernetes user can access the `retagentmgr` and `viya` namespaces.
- Confirm that these RAM Secrets exist in `retagentmgr`:
  - `retrieval-agent-manager-keycloak-client-secret`
  - `retrieval-agent-manager-keycloak-appadmin-secret`
- Confirm that the Keycloak realm contains the `Admin` and `User` groups.
- Confirm that the Keycloak server enables `admin-fine-grained-authz:v1` and `token-exchange`.
- Keycloak 26.7.0 or later is required for Identity Brokering API v2. The RAM API can use the
  available v1 endpoint on earlier versions.
- Confirm that Viya returns a numeric UID and GID for each user.
- Confirm that exactly one Viya NFS home export ends in `/homes`.
- Select a tested SAS MCP server image version. Do not use the `latest` tag.
- Install Docker on the computer that runs the helper.

The helper reads credential values from the two RAM Secrets. It does not display these values.

## Inputs

Prepare these non-secret values:

| Value | Example |
| --- | --- |
| Expected Kubernetes context | `aks-ram-prod` |
| Viya URL | `https://viya.example.com` |
| RAM URL | `https://ram.example.com` |
| MCP image with a tested version | `ghcr.io/sassoftware/sas-mcp-server:1.2.3` |

The helper asks you to enter these passwords in the local terminal:

- SAS boot password for `sasboot`.
- RAM Keycloak administrator password for `kcAdmin`.

The helper hides password input. Do not enter passwords in chat, command arguments, or environment
variables.

Optional inputs:

| Option | Default | Purpose |
| --- | --- | --- |
| `--ram-namespace` | `retagentmgr` | Set the RAM namespace. |
| `--viya-namespace` | `viya` | Set the Viya namespace. |
| `--release` | `retrieval-agent-manager` | Set the RAM Helm release name. |
| `--ca-file` | No additional CA | Verify a private certificate authority. |
| `--sso-only` | Full workflow | Run only the SAS Logon and RAM SSO stages. |
| `--mcp-only` | Full workflow | Verify existing SSO, then run only the MCP stages. |
| `--check-only` | Off | Check the current configuration. |

## Run the helper on Linux or macOS

Open a terminal in the `scripts/viya` directory.

The wrapper uses `~/.kube/config` by default. To use another Kubernetes configuration file, set its
absolute path:

```bash
export KUBECONFIG_PATH=/path/to/kubeconfig
```

First, enter the target values and ask the helper to check the current configuration:

```bash
./run-connect-ram-to-viya.sh \
  --check-only \
  --context <expected-context> \
  --viya-url https://<viya-host> \
  --ram-url https://<ram-host> \
  --mcp-image ghcr.io/sassoftware/sas-mcp-server:<tested-version>
```

Use the `--check-only` option to check the current cluster, URLs, existing SSO and MCP resources,
and the Viya home export. The helper does not create missing resources in this mode. It does not
query the Viya application registry in check-only mode.

Run the helper only after you confirm the context and input values:

```bash
./run-connect-ram-to-viya.sh \
  --context <expected-context> \
  --viya-url https://<viya-host> \
  --ram-url https://<ram-host> \
  --mcp-image ghcr.io/sassoftware/sas-mcp-server:<tested-version>
```

The helper shows the target and the planned changes. Enter `CONNECT` at the prompt to approve the
run. Enter both passwords at the hidden prompts.

For a private certificate authority, add `--ca-file` with the path to the certificate bundle:

```bash
./run-connect-ram-to-viya.sh \
  --context <expected-context> \
  --viya-url https://<viya-host> \
  --ram-url https://<ram-host> \
  --mcp-image ghcr.io/sassoftware/sas-mcp-server:<tested-version> \
  --ca-file /path/to/ca-bundle.pem
```

The wrapper builds the local `ram-connect-viya` image if that image is not present. To rebuild the
image after you change helper files, set `RAM_CONNECT_VIYA_REBUILD=true` before you run the wrapper.

To run only the SSO stages, add `--sso-only`. You do not need to provide `--mcp-image`:

```bash
./run-connect-ram-to-viya.sh \
  --sso-only \
  --context <expected-context> \
  --viya-url https://<viya-host> \
  --ram-url https://<ram-host>
```

To run only the MCP stages, add `--mcp-only`. The helper checks the existing SSO configuration first:

```bash
./run-connect-ram-to-viya.sh \
  --mcp-only \
  --context <expected-context> \
  --viya-url https://<viya-host> \
  --ram-url https://<ram-host> \
  --mcp-image ghcr.io/sassoftware/sas-mcp-server:<tested-version>
```

Do not use `--sso-only` and `--mcp-only` in the same command.

## Run the helper on Windows

Open PowerShell in the `scripts\viya` directory.

The wrapper uses `%USERPROFILE%\.kube\config` by default. To use another Kubernetes configuration
file, set its absolute path:

```powershell
$env:KUBECONFIG_PATH = "C:\path\to\kubeconfig"
```

First, check the current configuration:

```powershell
.\run-connect-ram-to-viya.ps1 `
  --check-only `
  --context <expected-context> `
  --viya-url https://<viya-host> `
  --ram-url https://<ram-host> `
  --mcp-image ghcr.io/sassoftware/sas-mcp-server:<tested-version>
```

Run the helper only after you confirm the target values. Remove `--check-only` from the command.
Enter `CONNECT` when the helper asks. Enter both passwords at the hidden prompts.

Set `$env:RAM_CONNECT_VIYA_REBUILD = "true"` to rebuild the local image.

## Resources

The helper creates or checks these resources:

| System | Resource |
| --- | --- |
| Viya | OAuth client `ram-client`, with authority `SASAdministrators` |
| Viya | Group and OAuth client `ram-app` |
| RAM Keycloak | Group `/Admin` |
| RAM Keycloak | Group `/User` |
| RAM Keycloak | Hardcoded group mapper `ram-admin-mapper` |
| RAM Keycloak | Hardcoded group mapper `ram-user-mapper` |
| Kubernetes | Secret `retrieval-agent-manager-viya-sso-client-secret` |
| Kubernetes | Secret `retrieval-agent-manager-viya-mcp-client-secret` |
| RAM Keycloak | Identity provider `viya-oidc` |
| RAM | MCP template and tools server `sas-mcp-tools` |
| RAM | MCP template and tools server `user-authenticated sas-mcp-tools` |
| Viya | Application registry entry `RetrievalAgentManager` |

The helper generates unique OAuth client secrets. It stores the secrets in Kubernetes Secrets. It
does not display the secrets.

The identity-provider mappers place each federated user in both `/Admin` and `/User`. RAM checks the
user's actual Viya `SASAdministrators` membership for admin-only API access. The helper does not
assign administrator access to one selected Viya user. It removes obsolete claim-based mappers named
`ram-admin-group-mapper` and `ram-user-group-mapper` when they exist.

The user-token tools server uses Keycloak token exchange to get a fresh Viya token from the signed-in
user's Keycloak session. Keycloak must have the `token-exchange` and
`admin-fine-grained-authz:v1` server features enabled. Keycloak 26.7.0 or later is required for the
Identity Brokering API v2 endpoint. Earlier versions can use the v1 endpoint when the RAM API selects
it.

## Verify the connection

After the helper reports success:

1. Confirm that a fresh SAS Logon token has issuer `{RAM_URL}/SASLogon/oauth/token`.
2. Open RAM and sign in through SAS Viya.
3. Confirm that a Viya `SASAdministrators` user can use RAM administrator functions.
4. Confirm that a regular Viya user cannot use RAM administrator functions.
5. Confirm that RAM appears in the Viya application menu.
6. Confirm that `sas-mcp-tools` is ready in RAM.
7. Confirm that `user-authenticated sas-mcp-tools` is ready in RAM.
8. Run an approved Viya tool through each tools server.

The tool checks are required. Resource creation alone does not prove that an MCP tools server can
call Viya or exchange a user token.

## Optional raw-token access to the RAM API

The helper does not set oauth2-proxy `extra_jwt_issuers`. That separate setting is required only when
a Viya process sends a raw Viya bearer token directly to the RAM API. It is not required for the two
MCP tools servers described here. Use the same issuer URI, `{RAM_URL}/SASLogon`, if your environment
needs this optional path.

## If a stage fails

The helper stops when a check or operation fails. It removes temporary home-directory Job resources
when it exits. Changes from completed stages remain. Review the reported resources with your
administrator before you run the helper again.

The helper keeps existing matching resources. It stops if a resource has a different configuration.
It does not delete or replace conflicting resources.

Do not remove or replace either generated OAuth client Secret after setup. The related integration
can stop working if a client secret is lost or changed.

For full input details and security notes, read the
[helper README](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/tree/main/scripts/viya).
