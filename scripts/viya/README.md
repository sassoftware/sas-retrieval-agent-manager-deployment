# Connect RAM to SAS Viya

Use this helper after you install SAS Retrieval Agent Manager (RAM). It connects RAM to a SAS Viya
deployment. It also creates two Model Context Protocol (MCP) tools servers.

The helper uses the current Kubernetes configuration. It does not use an Azure subscription ID,
resource group, cluster name, or hosting boundary.

## What the helper changes

The helper performs these actions in order:

1. Set SAS Logon `issuer.uri` to the RAM-facing SAS Logon URL.
2. Restart SAS Logon and verify its token issuer.
3. Connect RAM sign-in to SAS Viya single sign-on (SSO).
4. Create or update the Viya OAuth client with the `SASAdministrators` authority.
5. Configure the RAM Keycloak identity provider, hardcoded group mappers, and token exchange.
6. Update the RAM OAuth proxy login redirect and restart the RAM API and app deployments.
7. Create missing Viya home directories.
8. Create an OAuth client-credentials MCP tools server.
9. Create a user-token MCP tools server.
10. Register RAM in the Viya application menu.

The helper uses `kubectl`, Helm, HTTPS requests, and a temporary Kubernetes Job. It does not change
the Azure subscription or create Azure resources.

## Requirements

Before you run the helper, confirm these requirements:

- RAM is installed in the selected Kubernetes cluster.
- SAS Viya is available in the selected Kubernetes cluster.
- The current context targets the intended cluster.
- The current user can read Secrets and create or update the required resources in the `retagentmgr`
  namespace.
- The current user can read pods and persistent volumes in the Viya namespace.
- The RAM namespace contains the `retrieval-agent-manager-keycloak-client-secret` and
  `retrieval-agent-manager-keycloak-appadmin-secret` Secrets. The helper reads their values but does
  not print them.
- The Viya identity service returns a numeric UID and GID for each user.
- Exactly one Viya NFS home export ends in `/homes`.
- The Kubernetes cluster can pull `alpine:3.20` and the selected SAS MCP server image.
- The computer has Docker and access to the Kubernetes configuration file.
- Your computer can connect to the external RAM and Viya HTTPS URLs.
- The RAM Keycloak realm contains the `Admin` and `User` groups.
- The RAM Keycloak server enables `admin-fine-grained-authz:v1` and `token-exchange`.
- Keycloak 26.7.0 or later is required for Identity Brokering API v2. The RAM API can use the
  available v1 endpoint on earlier versions.

The home-directory Job runs as user ID 0. It mounts the Viya home export with write access. It
creates a directory only when that directory does not exist. It keeps existing directories. It skips
users without an identifier or a numeric UID and GID.

## Inputs

Provide these values when you run the helper:

| Input | Example | Description |
| --- | --- | --- |
| Kubernetes context | `aks-ram-prod` | The expected current context name. |
| Viya URL | `https://viya.example.com` | External SAS Viya URL. |
| RAM URL | `https://ram.example.com` | External RAM URL. |
| MCP image | `ghcr.io/sassoftware/sas-mcp-server:1.2.3` | MCP server image with a fixed version tag or digest. |

The helper asks for these passwords in the terminal:

- SAS boot password for the `sasboot` user.
- RAM Keycloak administrator password for the `kcAdmin` user.

The helper hides password input. Do not enter passwords in the command. Do not set passwords in
environment variables.

Optional inputs:

| Option | Default | Description |
| --- | --- | --- |
| `--ram-namespace` | `retagentmgr` | RAM namespace. |
| `--viya-namespace` | `viya` | SAS Viya namespace. |
| `--release` | `retrieval-agent-manager` | RAM Helm release. |
| `--ca-file` | No custom CA | CA certificate bundle for HTTPS verification. |
| `--sso-only` | Full workflow | Run only the SAS Logon and RAM SSO stages. |
| `--mcp-only` | Full workflow | Verify existing SSO, then run only the MCP stages. |
| `--check-only` | Off | Check existing resources without making changes. |

Do not use the `latest` MCP image tag. Use an image tag that your organization has tested.

## Use on Linux or macOS

Open a terminal in the `scripts/viya` directory.

If the Kubernetes configuration file is not `~/.kube/config`, set `KUBECONFIG_PATH` to its absolute
path:

```bash
export KUBECONFIG_PATH=/path/to/kubeconfig
```

To check the existing configuration without changes, run this command with the actual values:

```bash
./run-connect-ram-to-viya.sh \
  --check-only \
  --context <expected-context> \
  --viya-url https://<viya-host> \
  --ram-url https://<ram-host> \
  --mcp-image ghcr.io/sassoftware/sas-mcp-server:<tested-version>
```

Check-only mode checks the current cluster, URLs, existing SSO and MCP resources, and the Viya home
export. It does not create missing resources. It does not query the Viya application registry.

Before you run the full helper, verify the context and all input values. The helper shows the target
and the planned changes. Enter `CONNECT` in the terminal to approve the run. Then enter both
passwords at the hidden prompts.

```bash
./run-connect-ram-to-viya.sh \
  --context <expected-context> \
  --viya-url https://<viya-host> \
  --ram-url https://<ram-host> \
  --mcp-image ghcr.io/sassoftware/sas-mcp-server:<tested-version>
```

For a private certificate authority, add `--ca-file` and the local certificate path:

```bash
./run-connect-ram-to-viya.sh \
  --context <expected-context> \
  --viya-url https://<viya-host> \
  --ram-url https://<ram-host> \
  --mcp-image ghcr.io/sassoftware/sas-mcp-server:<tested-version> \
  --ca-file /path/to/ca-bundle.pem
```

The wrapper mounts the Kubernetes configuration and CA file as read-only files in the container.
The wrapper builds the local `ram-connect-viya` image when it is not present. To rebuild it after you
change the helper files, set `RAM_CONNECT_VIYA_REBUILD=true` before you run the wrapper.

To configure only SSO, add `--sso-only`. You do not need to provide `--mcp-image`.

```bash
./run-connect-ram-to-viya.sh \
  --sso-only \
  --context <expected-context> \
  --viya-url https://<viya-host> \
  --ram-url https://<ram-host>
```

To configure only MCP, add `--mcp-only`. The helper checks the existing SSO configuration first.

```bash
./run-connect-ram-to-viya.sh \
  --mcp-only \
  --context <expected-context> \
  --viya-url https://<viya-host> \
  --ram-url https://<ram-host> \
  --mcp-image ghcr.io/sassoftware/sas-mcp-server:<tested-version>
```

Do not use `--sso-only` and `--mcp-only` in the same command.

## Use on Windows

Open PowerShell in the `scripts\viya` directory.

If the Kubernetes configuration file is not `%USERPROFILE%\.kube\config`, set its absolute path:

```powershell
$env:KUBECONFIG_PATH = "C:\path\to\kubeconfig"
```

To check the existing configuration without changes, run:

```powershell
.\run-connect-ram-to-viya.ps1 `
  --check-only `
  --context <expected-context> `
  --viya-url https://<viya-host> `
  --ram-url https://<ram-host> `
  --mcp-image ghcr.io/sassoftware/sas-mcp-server:<tested-version>
```

To run the helper, remove `--check-only`. Confirm the target and enter `CONNECT` when the helper
asks. Then enter both passwords at the hidden prompts.

```powershell
.\run-connect-ram-to-viya.ps1 `
  --context <expected-context> `
  --viya-url https://<viya-host> `
  --ram-url https://<ram-host> `
  --mcp-image ghcr.io/sassoftware/sas-mcp-server:<tested-version>
```

For a private certificate authority, add `--ca-file` and the local certificate path. The PowerShell
wrapper mounts the file as read-only.

Set `$env:RAM_CONNECT_VIYA_REBUILD = "true"` to rebuild the local image.

## Resource names

The helper creates or checks these items:

| System | Name |
| --- | --- |
| Viya OAuth client | `ram-client`, with authority `SASAdministrators` |
| Viya group and OAuth client | `ram-app` |
| Keycloak group | `/Admin` |
| Keycloak group | `/User` |
| Keycloak hardcoded group mapper | `ram-admin-mapper` |
| Keycloak hardcoded group mapper | `ram-user-mapper` |
| Kubernetes Secret | `retrieval-agent-manager-viya-sso-client-secret` |
| Kubernetes Secret | `retrieval-agent-manager-viya-mcp-client-secret` |
| Keycloak identity provider | `viya-oidc` |
| RAM MCP template and tools server | `sas-mcp-tools` |
| RAM MCP template and tools server | `user-authenticated sas-mcp-tools` |
| Viya application registry entry | `RetrievalAgentManager` |

The `ram-client` and `ram-app` client secrets are generated by the helper and stored in the listed
Kubernetes Secrets. The helper does not display them.

Each federated user is placed in both Keycloak groups. RAM checks actual Viya `SASAdministrators`
membership for admin-only API access. The helper does not assign administrator access to one selected
user.

The helper removes obsolete `ram-admin-group-mapper` and `ram-user-group-mapper` claim-based mappers
when they exist.

The user-token tools server requires a RAM user who has signed in through Viya. Keycloak exchanges the
user's Keycloak token for a fresh Viya token. The helper sets the token-exchange permission and policy
for `sas-ram-app`.

## Repeat runs and failures

The helper keeps matching resources. It stops when a resource has a different configuration. It does
not delete or replace conflicting resources. Review the reported resource with your administrator
before you run the helper again.

If a stage fails, the helper stops. It removes temporary home-directory Job resources when its
process exits. Persistent Viya, Keycloak, Kubernetes, or RAM changes from completed earlier stages
remain. Review those resources before you retry.

Do not remove or change either generated OAuth client Secret after setup. A lost client secret can
stop the related integration from working.

## Verify the connection

After the helper reports success:

1. Confirm that a fresh SAS Logon token has issuer `{RAM_URL}/SASLogon/oauth/token`.
2. Open RAM and sign in through SAS Viya.
3. Confirm that a Viya `SASAdministrators` user can use RAM administrator functions.
4. Confirm that a regular Viya user cannot use RAM administrator functions.
5. Confirm that RAM appears in the Viya application menu.
6. In RAM, check that `sas-mcp-tools` is ready.
7. In RAM, check that `user-authenticated sas-mcp-tools` is ready.
8. Run an approved Viya tool through each tools server.

The final tool checks are required. A successful API response does not prove that the MCP workload
can call Viya or exchange a user token.

## Security notes

- Enter passwords only at the hidden prompts in the local terminal.
- Do not share terminal recordings or logs that could contain authentication data.
- The helper verifies HTTPS certificates. Do not disable certificate verification.
- The helper stores generated client secrets in Kubernetes Secrets.
- The home-directory Job needs write access to the Viya NFS home export and runs as user ID 0.
- The helper does not configure oauth2-proxy `extra_jwt_issuers`. Add this separate setting only if a
  caller must send a raw Viya bearer token directly to the RAM API. The source guide describes this
  optional path.
- The MCP templates use `ALLOW_RAW_BEARER=true` to pass bearer tokens to the SAS MCP server. Review
  this setting against your security policy before you run the helper.

## Files

The Linux and macOS wrapper is `run-connect-ram-to-viya.sh`.

The Windows wrapper is `run-connect-ram-to-viya.ps1`.

Both wrappers build and run the local image from `Dockerfile`.
