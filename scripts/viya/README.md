## Purpose

This script connects an existing SAS Viya deployment to an existing
SAS Retrieval Agent Manager (RAM) cluster. Single sign-on (SSO) lets RAM use
SASLogon for login. Model Context Protocol (MCP) lets a RAM tool server use
either the signed-in user's Viya token or a Viya OAuth client credential.

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
| `MCP_CLIENT_SECRET` | Secret for the MCP OAuth client; use a unique value |
| `RAM_URL` | External HTTPS origin for the existing RAM deployment |
| `RAM_KC_PASSWORD` | RAM Keycloak administrator password |
| `MCP_IMAGE` | Tagged SAS MCP server image available to the RAM cluster |

Set `KUBE_CONTEXT` if RAM and Viya share a cluster. If they are on separate clusters, comment out `KUBE_CONTEXT` and set both `RAM_KUBE_CONTEXT` and `VIYA_KUBE_CONTEXT`. Do not
set both forms. The wrapper reads the context values from the environment file.

Set a unique `MCP_CLIENT_SECRET` for this deployment. If you omit it, the
wrapper uses the existing automation default.
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

1. Check that the selected cluster has the existing RAM and SAS Logon resources.
2. Create missing Viya home directories for users with Viya identifiers.
   The wrapper creates a temporary Job in the Viya namespace and removes its
	Job, ConfigMap, and Secret after it finishes.
3. Set the SASLogon issuer through the SAS Configuration API if it differs.
	 Restart SAS Logon and check a new token after a change.
4. Run the attached `link_viya_identity.sh` without changes. Run
	`enable_idp_token_exchange.sh`, which uses the same API calls and policy
	settings as the original Python permission script. Check that
	Keycloak stored the issuer and client from Viya.
5. Set `kc_idp_hint` and the Viya JWT issuer in the shared RAM oauth2-proxy
	 ConfigMap. Restart the RAM API and app deployments if the file changes.
6. Register RAM in the Viya application registry.
7. Create or check the `sas-mcp-tools` OAuth template and server and the
	 `user-authenticated sas-mcp-tools` template and server in RAM. Publish both
	 templates and start both servers.

Confirm the MCP deployment is ready in RAM before you use its tools.
