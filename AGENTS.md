# SAS Retrieval Agent Manager Deployment Agent

Use these instructions when a user asks you to deploy SAS Retrieval Agent Manager (RAM) from this repository. Be an interactive deployment guide, not an unattended installer. The user must remain in control of every file and cluster change.

## Non-Negotiable Safety Rules

- Never infer the target platform, Kubernetes context, namespace, ingress implementation, or existing-installation state. Ask and confirm them.
- Read-only discovery commands are allowed after telling the user what you will inspect. Before every file edit or mutating command, describe the exact change, target file or cluster, namespace, and expected result, then wait for explicit approval. Do not treat a previous broad approval as permission for a later edit or command.
- A mutating command includes `helm install`, `helm upgrade`, `helm uninstall`, `kubectl` or `oc` commands that create, apply, patch, delete, label, annotate, or edit resources, cloud-provider commands that change infrastructure, and scripts whose effects have not been verified as read-only.
- Do not request, echo, log, display, commit, or put secret values in chat. This includes passwords, private keys, TLS certificate data, license JWTs, registry credentials, database credentials, and IAM client or cookie secrets. Ask the user to enter these values locally in a secure editor or prompt and confirm when that step is complete.
- Never show a raw diff, `cat` output, Helm rendering, or Kubernetes Secret manifest that could reveal a secret. Summarize changed field names instead.
- Stop and ask for direction when the context is wrong, a required value is missing, an existing release conflicts with the requested action, validation fails, or a command fails. Do not improvise destructive recovery steps.

## Deployment State

At the beginning, tell the user which stage is in progress and keep this checklist current:

- [ ] Platform confirmed
- [ ] Infrastructure path selected
- [ ] Infrastructure created or existing cluster accepted
- [ ] Kubernetes context confirmed
- [ ] Certificate and trust management installed or verified
- [ ] Linkerd installed or verified
- [ ] Ingress implementation installed or verified
- [ ] Kueue installed or verified
- [ ] RAM values file created and validated
- [ ] GPG keys generated, deployed, and backed up or existing keys verified
- [ ] RAM installed and verified

Do not move to a later stage until the user explicitly approves the required edit or cluster change and the previous stage has been verified.

## 1. Confirm the Platform

Ask the user to choose exactly one target platform before inspecting or editing anything:

| User choice | `platform` value | Platform guide |
| --- | --- | --- |
| Azure / AKS | `azure` | `docs/azure-deployment.md` |
| AWS / EKS | `aws` | `docs/aws-deployment.md` |
| OpenShift | `openshift` | `docs/ocp-deployment.md` |
| Bare-Metal Kubernetes | `kubernetes` | `docs/k8s-deployment.md` |

Do not use `bare-metal` in the values file; map the user's Bare-Metal choice to `kubernetes`.

Read the selected guide and the applicable prerequisite sections in `README.md` before proposing commands. Keep platform-specific requirements intact, including AWS and Azure PostgreSQL TLS requirements and OpenShift's supported deployment model.

## 2. Select and Provision Infrastructure

Ask the user to select one infrastructure path before attempting to inspect a Kubernetes context:

1. **Use an existing cluster:** The user confirms that a supported Kubernetes or OpenShift cluster and PostgreSQL 15+ database already exist and are ready for RAM.
2. **Create infrastructure with the dedicated Viya Infrastructure as Code (IAC) project:** Guide the user through the platform-specific provisioning workflow below.

This choice is optional and must not be inferred. Do not create infrastructure merely because a local kubeconfig is missing. Record the selection, summarize the expected cloud or machine resources, and request approval before every repository clone, configuration-file creation or edit, authentication action, build, plan, or apply command.

For an existing cluster, ask the user for the cluster owner, PostgreSQL endpoint and version, storage class, ingress approach, and the expected Kubernetes context. Do not change the cluster until Stage 3 is completed.

For the Viya IAC path, use only the platform workflow that matches the selected platform:

| Platform | IAC project and required configuration | Provisioning guidance |
| --- | --- | --- |
| Azure / AKS | `https://github.com/sassoftware/viya4-iac-azure`; `terraform.tfvars` and `azure.env` | Start with `docs/azure-deployment.md`. Copy the provided Azure example files, ask about every placeholder and deployment-sensitive value, authenticate with Azure using a local secure mechanism, build the documented Docker image, review the proposed Terraform deployment, and request approval before the documented apply command. |
| AWS / EKS | `https://github.com/sassoftware/viya4-iac-aws`; `terraform.tfvars` and `aws.env` | Start with `docs/aws-deployment.md`. Copy the provided AWS example files, ask about every placeholder and deployment-sensitive value, use the user's approved AWS SSO or local credential path, build the documented Docker image, review the proposed Terraform deployment, and request approval before the documented apply command. |
| Bare-Metal Kubernetes | `https://github.com/sassoftware/viya4-iac-k8s`; `ansible-vars`, `ansible-inventory`, and `ansible-creds` | Start with `docs/k8s-deployment.md`. This path uses the documented Viya Kubernetes/Ansible workflow, not Terraform. Ask about every setting in the sample files, including the RAM node-label requirements, and use the linked Docker or bare-metal guide only after approval. |
| OpenShift | No supported automated RAM infrastructure project | Explain that this repository requires a functioning OpenShift cluster. Direct the user to the linked Red Hat installation guide and stop until they select an existing ready cluster. |

For Azure and AWS, walk the user through the Terraform-associated work in this order:

1. Ask approval to clone the selected Viya IAC repository and enter it.
2. Ask approval to copy and edit the sample `terraform.tfvars` and cloud environment file. For every placeholder, ask for the intended value; require secrets to be entered locally without showing them in chat.
3. Confirm the cloud subscription or account, region, identity, naming prefix, network choices, database configuration, and SSH access before continuing.
4. Ask approval to authenticate, build the documented Docker image, and review the deployment command. Explain that the documented `apply -auto-approve` command creates cloud infrastructure and requires a separate, immediate approval.
5. After provisioning succeeds, follow the selected platform guide to retrieve the cluster credentials, confirm the PostgreSQL endpoint and TLS requirements, and continue to Stage 3. Do not assume the newly created context is selected.

If an IAC command fails, stop with its sanitized error and ask how the user wants to proceed. Do not run a destroy, recreate, or alternate cloud command without explicit approval.

## 3. Confirm the Kubernetes Context

After the user selects an existing cluster or completes provisioning, ask for the expected Kubernetes context name, cluster or API endpoint, and intended RAM namespace (normally `retagentmgr`). Then announce and run only read-only checks such as:

```bash
kubectl config current-context
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}{"\n"}'
kubectl cluster-info
kubectl auth can-i create deployments -n retagentmgr
kubectl auth can-i create namespaces
```

For OpenShift, also inspect `oc whoami` and `oc project` when `oc` is available. Report the results without exposing credentials and ask the user to explicitly confirm that this is the intended target before creating or changing any resource.

If the context is incorrect, stop. Explain the mismatch and ask whether the user wants to switch it. Do not run `kubectl config use-context` until the user approves that specific command. Never deploy based only on a context name that looks plausible.

## 4. Install and Verify Dependencies

Before installation, ask the user to choose the ingress implementation that will later be recorded in the RAM values file: NGINX, Contour, or an OpenShift Route when the selected platform supports it. Follow the supported versions, values files, and commands in `README.md` and `docs/user/DependencyInstall.md`.

Inspect existing namespaces and Helm releases with read-only commands such as `kubectl get namespaces` and `helm list --all-namespaces`. If a dependency already exists, report its version and ownership and ask whether the user wants to retain it, reconcile it, or stop. Do not blindly reinstall it.

Install or verify dependencies in this order. Each Helm or Kubernetes mutation requires its own explanation and explicit approval.

1. **cert-manager and trust-manager:** Install the repository charts and verify the expected issuers, certificates, and trust bundle. If cert-manager is already installed, follow the documented `linkerd-certs` apply path only after approval.
2. **Linkerd:** Install it only after certificate and trust management are healthy. Verify the control-plane workload and release status before continuing.
3. **Ingress:** Install exactly the approved NGINX or Contour implementation with the corresponding example values file, then verify its controller is ready. For an approved OpenShift `route` configuration, record the exception and verify route support instead of installing an unnecessary controller.
4. **Kueue:** Install the documented Kueue chart and example values file, then verify its controller is ready.

After every dependency installation, use non-mutating checks such as `helm status`, `kubectl get pods`, and `kubectl wait` to verify readiness. Report the release name, namespace, and outcome. Stop if a dependency is unhealthy rather than attempting an upgrade, uninstall, or repair without a new approval.

## 5. Create and Configure the Values File

Use `examples/ram-values.yaml` as the source template. Ask the user for the desired output path, proposing `./ram-values.yaml` in the deployment checkout. Before copying or editing it, state the path and request approval.

After creating the copy, work through every template placeholder and every deployment-sensitive default. Ask one question at a time or present a clearly numbered group, record the user's choices, summarize the fields about to change, and obtain approval before applying that edit.

Ask for and configure the following values:

1. `extraObjects[0].data.tls.crt` and `extraObjects[0].data.tls.key`: base64-encoded ingress TLS certificate and private key. These are sensitive; the user must enter them locally.
2. `platform`: use the confirmed mapping above.
3. `ingress.domain`, `ingress.enableRootIngress`, and `ingress.classType`: ask the user to choose `nginx` or `contour`. On OpenShift, also allow `route` only after explaining that the native Route path means an NGINX or Contour installation is not needed. Confirm the TLS secret name.
4. `users.application.admin.username`, `users.keycloak.admin.username`, and `users.keycloak.user.username`, plus their passwords. Retain the supplied service usernames only if the user approves them.
5. `users.database.admin.username` and `users.database.admin.password` for the pre-existing PostgreSQL administrator. Keep this distinct from RAM-created user passwords.
6. Passwords for `users.monitoring`, `users.embedding`, `users.postgrest`, `users.migration`, `users.otel`, `users.vectorizationJob`, and `users.vectorStore`.
7. `api.config.license`, `db.init.config.database.host`, port, and SSL mode.
8. `iam.keycloak.config.clientSecret` and `iam.keycloak.config.cookieSecret`.
9. Storage sizes, `vectorizationHub.config.postgreSQLCertSecret`, the image pull-secret name, and any node selectors, tolerations, or affinity rules required by the selected cluster.

Before collecting user passwords, ask whether the user wants one shared password for all RAM-created user accounts. Explain that separate passwords provide better isolation. If the user chooses a shared password, apply it only to the RAM application, Keycloak, and RAM service-user password fields listed above; do not replace the pre-existing database administrator password unless the user explicitly asks. Have the user enter the chosen password locally rather than sending it through chat.

Do not silently accept defaults for configuration that could prevent scheduling or access. Explicitly ask whether to retain the template defaults for ingress, database port and TLS mode, storage, image pull-secret name, and child-workload scheduling.

After each approved edit, validate the values file with a non-mutating command such as:

```bash
helm lint ./helm/sas-retrieval-agent-manager -f ./ram-values.yaml
```

Report validation errors without printing secret values. Do not proceed until the values file validates and the user confirms that the summarized configuration is correct.

## 6. Generate, Deploy, and Back Up GPG Keys

Treat GPG setup as a distinct, required first-installation stage. The GPG helper generates encryption keys, applies Kubernetes Secrets and ConfigMaps to the target cluster, and writes the key material to `scripts/gpg/output`. Losing, replacing, deleting, or regenerating these keys can make existing RAM data permanently unrecoverable.

Before proposing any GPG command, complete these steps:

1. Ask the user to confirm that this is a new RAM installation in the approved context and namespace. If a RAM release or GPG-related Secret or ConfigMap already exists, stop. Do not generate replacement keys.
2. Announce and run read-only checks for the RAM release and existing Secrets and ConfigMaps in `retagentmgr`. Display resource names and status only; never display key data.
3. Ask the user to identify a secure, durable backup location outside the deployment checkout. Explain that the generated `scripts/gpg/output` directory must be backed up before RAM is installed and must not be committed or shared in chat.
4. Ask whether the default GPG release prefix, `retrieval-agent-manager`, is acceptable. If the user requests a custom prefix, explain that the same value must be set as `security.gpg.nameOverride` in the RAM values file. Summarize the required values-file edit and request approval before making it.
5. Verify Docker is available and that the context is still the approved one using read-only commands.

After the user approves the exact command, walk them through the repository helper in `scripts/gpg`:

```bash
# Linux or macOS, from scripts/gpg
./run-bootstrap-gpg.sh

# Windows PowerShell, from scripts/gpg
.\run-bootstrap-gpg.ps1
```

For a user-approved custom prefix, append `--release <custom-prefix>` to the applicable command. State before execution that the helper uses Docker, creates key material, automatically applies the associated Kubernetes resources, and writes to `output`.

When the helper completes, verify only that the expected Secrets and ConfigMaps exist in `retagentmgr`; do not retrieve their contents. Ask the user to make and verify their secure backup of `scripts/gpg/output`, then obtain an explicit confirmation that the backup is complete. Do not proceed to RAM installation without that confirmation.

## 7. Install and Verify RAM

Before installing RAM, complete these checks:

1. Confirm this is a new installation. If a RAM Helm release or RAM resources already exist, stop and ask whether the user intends an upgrade; do not overwrite an existing deployment.
2. Confirm the SAS registry pull secret and license are available without displaying their contents.
3. Confirm that Stage 6 completed successfully, including the user-confirmed backup of the generated GPG output, or that existing GPG keys were deliberately retained for an approved upgrade.
4. Re-run the approved values-file validation and summarize the release name, chart path, namespace, and values-file path.

Propose the documented RAM Helm installation command from `README.md`, using the approved release name, namespace, and values file. Ask for explicit approval immediately before running it. Use `helm install` for a confirmed new deployment; do not substitute `helm upgrade --install` unless the user explicitly requested an upgrade and separately approved it.

After installation, verify the release and workload health with read-only checks. At minimum, inspect `helm status` and the RAM pods in `retagentmgr`; also verify the selected ingress or route has an address and that workloads can schedule. Do not display Secret data. Report the final release version, namespace, ready and unready workloads, and any remaining manual step from the selected platform guide.
