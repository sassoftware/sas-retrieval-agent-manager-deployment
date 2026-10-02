We need to link Viya SSO and MCP server to RAM using already existing workflows, automations, and scripts.

## Scope

The Docker wrapper connects an existing SAS Viya deployment to an existing
SAS Retrieval Agent Manager (RAM) cluster. Single sign-on (SSO) lets RAM use
SASLogon for login. Model Context Protocol (MCP) lets a RAM tool server use
the signed-in user's Viya token.

The wrapper does not install RAM. It does not create Viya home directories.
It does not add RAM to the Viya application list.

## Before You Run

- Confirm the Kubernetes context and the RAM and Viya namespaces.
- Confirm that the RAM API and app deployments and the SAS Logon deployment exist.
- Use a Keycloak build with `token-exchange` and `admin-fine-grained-authz:v1`.
	Use `identity-brokering-api:v2` if the RAM version needs that endpoint.
- Use an MCP image that serves HTTP at port `8134` and path `/mcp`.
	The image must accept `VIYA_ENDPOINT` and `ALLOW_RAW_BEARER`.
- Install Docker, `kubectl`, and `jq` on the Linux host. For a Kubernetes
	context that uses Azure CLI login, also install `az` and `kubelogin`.
- Give the Kubernetes identity permission to read the existing RAM Secrets,
	change the RAM oauth2-proxy ConfigMap, restart the RAM deployments, and
	change the SAS Logon configuration and deployment.

Create a private Docker environment file outside this directory. Set these
values in that file. Use `NAME=value` lines without `export` or shell quotes.
Do not put the file in version control.

| Name | Value |
| --- | --- |
| `VIYA_URL` | External HTTPS origin for Viya, for example `https://viya.example.com` |
| `VIYA_USER` | Viya administrator user |
| `VIYA_PASSWORD` | Viya administrator password |
| `VIYA_CLIENT_SECRET` | Secret for the Viya SSO OAuth client; do not use the manual script's default |
| `RAM_URL` | External HTTPS origin for the existing RAM deployment |
| `RAM_KC_PASSWORD` | RAM Keycloak administrator password |
| `MCP_IMAGE` | Tagged SAS MCP server image available to the RAM cluster |

Optional values are `VIYA_CLIENT_ID`, `RAM_KC_USER`, `RAM_KC_REALM`,
`RAM_KC_CLIENT_ID`, `IDP_ALIAS`, `RAM_KC_ADMIN_GROUP`, `RAM_KC_USER_GROUP`,
`VIYA_NAMESPACE`, `RAM_NAMESPACE`, `RAM_RELEASE`, `ISSUER_URI`, and
`SSL_VERIFY`.
The script reads `RAM_KC_REALM` and `RAM_KC_CLIENT_ID` from the existing
RAM Secret. If you set either value, it must match the Secret.
The default namespaces are `viya` and `retagentmgr`. The default RAM Helm
release is `retrieval-agent-manager`. The default issuer is
`{VIYA_URL}/SASLogon`. Set `ISSUER_URI` to a different external HTTPS
`/SASLogon` URL only if RAM can reach it and Viya uses it for its tokens.

Use one context and one Kubernetes configuration file when RAM and Viya share
a cluster. Use `--context` and `--kubeconfig` for that case.

```bash
bash run-viya-connection.sh \
	--context <confirmed-context> \
	--env-file /private/path/viya.env
```

Use separate contexts and configuration files when RAM and Viya use different
clusters:

```bash
bash run-viya-connection.sh \
	--ram-context <ram-context> \
	--viya-context <viya-context> \
	--ram-kubeconfig /private/path/ram-kubeconfig \
	--viya-kubeconfig /private/path/viya-kubeconfig \
	--env-file /private/path/viya.env
```

For PowerShell 7, use `-Context` for a shared cluster or these parameters for
separate clusters:

```powershell
./run-viya-connection.ps1 -RamContext <ram-context> -ViyaContext <viya-context> `
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
2. Set the SASLogon issuer through the SAS Configuration API if it differs.
	 Restart SAS Logon and check a new token after a change.
3. Run the attached `link_viya_identity.sh` without changes. Run
	`enable_idp_token_exchange.sh`, which uses the same API calls and policy
	settings as the original Python permission script. Check that
	Keycloak stored the issuer and client from Viya.
4. Set `kc_idp_hint` and the Viya JWT issuer in the shared RAM oauth2-proxy
	 ConfigMap. Restart the RAM API and app deployments if the file changes.
5. Create or check the `user-authenticated sas-mcp-tools` template and tool
	 server in RAM. Publish the template and start the server. Stop on a
	 same-named resource with different settings.

Confirm the MCP deployment is ready in RAM before you use its tools.

A Helm upgrade can replace a direct ConfigMap change. Check the settings
after an upgrade. The attached SSO scripts use `curl -k`. The token-exchange
script does not verify TLS certificates unless `SSL_VERIFY=true` is set.
Use this workflow only on a trusted network until certificate verification
is configured for these scripts.

Before a real user runs Viya compute through RAM, create that user's Viya
home directory with the correct Viya UID and GID. The home-directory step
is separate from this wrapper. Use the existing [connection check](tests/connection-test.py)
from a Viya session after the user's groups and home directory are ready.