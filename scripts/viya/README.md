## Purpose

This script connects an existing SAS Viya deployment to an existing
SAS Retrieval Agent Manager (RAM) cluster. Single sign-on (SSO) lets RAM use
SASLogon for login. Model Context Protocol (MCP) lets a RAM tool server use
either the signed-in user's Viya token or a Viya OAuth client credential.

Set the applicable skip setting to `true` in the environment file to skip a
connection step. Each setting defaults to `false` when absent. Only `true`
and `false` are valid. An empty value is not valid.

| Setting | Step skipped when `true` |
| --- | --- |
| `SKIP_HOME_DIRECTORIES` | Viya home directory creation |
| `SKIP_MCP_SERVERS` | MCP OAuth client setup, template creation and publication, and server creation and startup |
| `SKIP_RAM_APP_REGISTRATION` | RAM registration in the Viya application registry |
| `SKIP_VIYA_GROUP_MEMBERS` | Addition of `SASAdministrators` to `ram-admin-group` |

For example, use these values to skip the three optional connection steps:

```dotenv
SKIP_MCP_SERVERS=true
SKIP_RAM_APP_REGISTRATION=true
SKIP_VIYA_GROUP_MEMBERS=true
```

The settings are independent. Both host wrappers use the same settings.
Skipping a step does not remove existing resources or group members.
The group membership setting does not skip group creation or display names.

## Before You Run

- Confirm the Kubernetes context and the RAM and Viya namespaces.
- Confirm that the RAM, SAS Logon, and Viya deployments exist in their respective namespaces and contexts.
- Install Docker, `kubectl`, and `jq` on the host running the wrapper script.
> **Note**: For a Kubernetes context that uses Azure CLI login, also install `az` and `kubelogin` on the host.

Generate two unique OAuth client secrets. Run this command twice on the host:

```bash
openssl rand -hex 32
```

Use one value for `VIYA_CLIENT_SECRET`. Use the other value for
`MCP_CLIENT_SECRET`. Do not reuse a value. Do not send a generated value in
chat.

Create a private Docker environment file outside this directory. Set these
values in that file. Use `NAME=value` lines without `export` or shell quotes.
Do not put the file in version control.

| Name | Value |
| --- | --- |
| `VIYA_URL` | External HTTPS origin for Viya, for example `https://viya.example.com` |
| `VIYA_USER` | Viya administrator user |
| `VIYA_PASSWORD` | Viya administrator password |
| `VIYA_CLIENT_SECRET` | Secret for the Viya SSO OAuth client; do not use the manual script's default |
| `MCP_CLIENT_ID` | Client ID for the MCP OAuth server; defaults to `ram-app` |
| `MCP_CLIENT_SECRET` | Secret for the MCP OAuth client; use a unique value when MCP setup is enabled |
| `RAM_URL` | External HTTPS origin for the existing RAM deployment |
| `RAM_KC_PASSWORD` | RAM Keycloak administrator password |
| `MCP_IMAGE` | Tagged SAS MCP server image available to the RAM cluster; not required when `SKIP_MCP_SERVERS=true` |

The issuer update uses `VIYA_USER` and `VIYA_PASSWORD`. This account must have
permission to change the SAS Logon configuration. The script does not read the
initial `sasboot` password.

Set `KUBE_CONTEXT` if RAM and Viya share a cluster. If they are on separate clusters, comment out `KUBE_CONTEXT` and set both `RAM_KUBE_CONTEXT` and `VIYA_KUBE_CONTEXT`. Do not
set both forms. The wrapper reads the context values from the environment file.

When MCP setup is enabled, set a unique `MCP_CLIENT_SECRET` for this deployment.
If you omit it, the wrapper uses the existing automation default.
When `SKIP_MCP_SERVERS=true`, the runner does not require the MCP settings
or the RAM application-account Secret. The runner still configures the
identity provider and token-exchange permissions for single sign-on.
The script reads `RAM_KC_REALM` and `RAM_KC_CLIENT_ID` from the existing
RAM Secret. If you set either value, it must match the Secret.
The default namespaces are `viya` and `retagentmgr`. The default RAM Helm
release is `retrieval-agent-manager`. The default issuer is
`{VIYA_URL}/SASLogon`. Set `ISSUER_URI` to a different external HTTPS
`/SASLogon` URL only if RAM can reach it and Viya uses it for its tokens.

When RAM and Viya share a cluster, set `KUBE_CONTEXT` in the environment file.
Use this command:

```bash
bash run-viya-connection.sh --env-file /private/path/viya.env
```

When RAM and Viya use separate clusters, set both context values in the
environment file. Add the kubeconfig options only when you use non-default
Kubernetes configuration files:

```bash
bash run-viya-connection.sh \
	--ram-kubeconfig /private/path/ram-kubeconfig \
	--viya-kubeconfig /private/path/viya-kubeconfig \
	--env-file /private/path/viya.env
```

For PowerShell 7, set the context values in the environment file. Add the
kubeconfig parameters only when you use non-default Kubernetes configuration
files:

```powershell
./run-viya-connection.ps1 `
	-RamKubeconfig C:\private\ram-kubeconfig `
	-ViyaKubeconfig C:\private\viya-kubeconfig `
	-EnvFile C:\private\viya.env
```

The PowerShell wrapper uses `-Kubeconfig FILE` as the shared configuration
file. Use `-RamKubeconfig` and `-ViyaKubeconfig` for separate files. It does
not require `jq` on the host. Use Linux containers in Docker Desktop. Enable
host networking in Docker Desktop if required.

Use `--kubeconfig FILE` as the shared configuration file. Use
`--ram-kubeconfig FILE` and `--viya-kubeconfig FILE` for separate files. The
wrapper builds a local Docker image. The wrapper uses the host network and
mounts temporary Kubernetes configuration files read-only. For Azure CLI
login, it gets a short-lived token on the host for each context. It removes
the temporary files when Docker exits. Do not share the Docker environment
file or the Kubernetes configuration files.

## Changes Made

The following list describes the default steps. The skip settings above
disable only their applicable steps.

1. Check that the selected cluster has the existing RAM and SAS Logon resources.
2. Create missing Viya home directories for users with Viya identifiers.
   The wrapper creates a temporary Job in the Viya namespace and removes its
	Job, ConfigMap, and Secret after it finishes.
3. Set the SASLogon issuer through the SAS Configuration API if it differs.
	 Restart SAS Logon and check a new token after a change.
4. Run `link_viya_identity.sh`. Set the Viya group display names to `RAM Admin`
   and `RAM User`. Set the group descriptions. Add `SASAdministrators` as a
   member of `ram-admin-group`. Keep both group IDs unchanged.
   Run `enable_idp_token_exchange.sh`. Check that Keycloak stored the issuer
   and client from Viya.
5. Set `kc_idp_hint` and the Viya JWT issuer in the shared RAM oauth2-proxy
	 ConfigMap. Restart the RAM API and app deployments if the file changes.
6. Register RAM in the Viya application registry.
7. Create or check the `sas-mcp-tools` OAuth template and server and the
	 `user-authenticated sas-mcp-tools` template and server in RAM. Publish both
	 templates and start both servers.

Confirm the MCP deployment is ready in RAM before you use its tools.

## Viya Groups

Both host wrappers run [rename_viya_group.sh](./lib/rename_viya_group.sh) and
[add_viya_group_member.sh](./lib/add_viya_group_member.sh) after
[link_viya_identity.sh](./lib/link_viya_identity.sh). The Docker image contains
both group scripts. Set `SKIP_VIYA_GROUP_MEMBERS=true` to skip the membership
script during setup. The name script still runs.

The display names do not change the group IDs. The single sign-on group
mappings still use `ram-admin-group` and `ram-user-group`.
Set these optional values in the private environment file to use other
display text:

| Name | Default value |
| --- | --- |
| `RAM_ADMIN_GROUP_NAME` | `RAM Admin` |
| `RAM_ADMIN_GROUP_DESC` | `Users with admin access to Retrieval Agent Manager` |
| `RAM_USER_GROUP_NAME` | `RAM User` |
| `RAM_USER_GROUP_DESC` | `Users with user access to Retrieval Agent Manager` |

The membership step changes only `ram-admin-group`. It does not change
`SASAdministrators`. Both scripts check the current state before a change.
Both scripts verify each change. A failed request or verification stops setup.

After setup, sign in with a SAS administrator account. Check the Viya token.
The `authorities` claim must contain `ram-admin-group` for RAM administrator
access. A nested group does not always add this value to the token.
If the value is absent, add the required users directly to `ram-admin-group`
in Viya.

### Run a Group Script Separately

Use a shell with `VIYA_URL`, `VIYA_USER`, and `VIYA_PASSWORD` already set.
Do not enter passwords in chat. Install `curl` and `jq` before use.
The name script also requires `awk`.

Preview each change without a write:

```bash
DRY_RUN=1 bash lib/rename_viya_group.sh
DRY_RUN=1 bash lib/add_viya_group_member.sh
```

Apply the group changes:

```bash
bash lib/rename_viya_group.sh
bash lib/add_viya_group_member.sh
```

Remove the nested administrator group when required:

```bash
REMOVE=1 bash lib/add_viya_group_member.sh
```

For separate use, the membership script accepts `PARENT_GROUP_ID` and
`MEMBER_GROUP_ID`. The name script accepts `RAM_ADMIN_GROUP_ID` and
`RAM_USER_GROUP_ID`. Use the default IDs for the full connection setup.
Use `DRY_RUN` and `REMOVE` only with the separate group scripts.
These settings do not control the full connection setup.

## Script Format

Each script has a purpose, requirements, usage, and optional settings in its
header. Bash scripts use two-space indentation and `function name()` declarations.
PowerShell and Python scripts keep their language syntax and four-space
indentation. Existing command options and required environment names are unchanged.

## Testing the Connection

After completing the setup, you can test the connection between SAS Viya and RAM using the provided [connection check script](./tests/connection-test.py) in SAS Studio.
