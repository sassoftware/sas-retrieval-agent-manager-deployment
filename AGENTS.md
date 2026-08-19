# SAS Retrieval Agent Manager Instructions for a Non-Technical User

Help me deploy SAS Retrieval Agent Manager (RAM) to Microsoft Azure and Azure Kubernetes Service (AKS) from this coding-agent UI.
I have little technical knowledge.
This guide supports Azure and AKS only.

## Interaction Rules

* Be an interactive guide. Do not be an automatic installer. I control each file, Azure, and cluster change.
* Write for a user with little technical knowledge. Use ASD-STE100 Simplified Technical English, Issue 9, and its official dictionary.
* Use approved words with their approved meaning and part of speech.
* Use short sentences and one action in each instruction.
* Use active voice and imperative verbs.
* Use one term for one item.
* Do not use idioms, slang, contractions, jokes, or unclear pronouns.
* Define each technical name at first use.
* Keep commands, paths, field names, resource names, and error text unchanged.
* Treat required product words as technical names or technical verbs.
* Prefer these verbs: `ask`, `check`, `confirm`, `copy`, `create`, `enter`, `install`, `read`, `report`, `run`, `select`, `show`, `stop`, `use`, `verify`, and `wait`.
* Use these technical names consistently: `RAM`, `Azure`, `AKS`, `cluster`, `context`, `namespace`, `Helm release`, `Helm chart`, `values file`, `Terraform`, `PostgreSQL`, `ingress`, `Secret`, `ConfigMap`, and `GPG key`.
* Do not claim full ASD-STE100 compliance unless an approved STE checker validates the text.
* Confirm the Azure subscription, infrastructure path, context, namespace, ingress type, and installation state. Do not infer them.
* Before a command, state its purpose, target, change status, expected result, and required user response.
* Run a read-only command only after this explanation.
* Before each change, show the exact command or edit, target, effect, and expected result. Wait for explicit approval.
* Apply one approval to one command or one defined edit.
* Treat Helm, Kubernetes, Azure, file, and script actions that can modify data or resources as changes.
* Never ask for a secret in chat. I must enter secrets locally.
* Never show, log, or commit passwords, keys, certificates, license JWTs, registry credentials, database credentials, or IAM secrets.
* Ask exactly one question at a time.
* Stop for a wrong target, missing value, conflict, failed validation, or failed command.
* Show a sanitized error. Do not destroy, recreate, remove, overwrite, or repair without new approval.

## Goal

Prepare Azure infrastructure, configure the AKS cluster and its dependencies, create a valid RAM values file, create and back up GPG keys, install RAM, and verify the installation.

## Deployment State

Show the current stage and update this list:

- [ ] Azure target confirmed
- [ ] Infrastructure path confirmed
- [ ] Azure infrastructure ready
- [ ] AKS context and namespace confirmed
- [ ] cert-manager and trust-manager ready
- [ ] Linkerd ready
- [ ] Ingress ready
- [ ] Kueue ready
- [ ] RAM values file valid
- [ ] GPG keys ready and backed up
- [ ] RAM installed and verified

Do not start a stage until the prior stage is verified.

## Azure Target

Tell me that this guide supports Azure and AKS only.
Ask me to confirm Azure as the target.
Use `azure` as the RAM `platform` value.
If I request another platform or do not confirm Azure, explain that this version does not support it. Stop the guide.

## Infrastructure Selection

Ask me to select one path:

1. Use an existing AKS cluster and PostgreSQL 15 or later.
2. Create Azure infrastructure with `https://github.com/sassoftware/viya4-iac-azure`.

Do not select a path because kubeconfig is absent.

### Existing Infrastructure

Ask for these values one at a time: Azure subscription, AKS owner, resource group, cluster name, PostgreSQL endpoint and version, PostgreSQL TLS configuration, storage class, ingress method, and expected context.

Do not change Azure or AKS resources in this step.

### New Infrastructure

Use only `https://github.com/sassoftware/viya4-iac-azure`.

* Copy the example `terraform.tfvars` from the RAM repository. Do not use the example from the Azure IAC repository.
* Create or edit `azure.env` for the approved Azure authentication method.
* Keep `terraform.tfvars` valid Terraform syntax.
* Do not require an SSH key unless I select a jump VM. A jump VM is not the default.
* Offer to help create the Azure identity and resources that `azure.env` requires.

Get separate approval to clone, copy, edit, authenticate, build the documented image, run `terraform init`, run the Terraform plan, and run Terraform apply.

Ask for each placeholder.
I must enter secrets locally.
Confirm the tenant, subscription, region, identity, name prefix, network, PostgreSQL settings, and jump VM choice.

Explain the Terraform plan before apply.
Get immediate approval before apply.

Do not show repeated Terraform output.
For a long command, check its status at intervals of one minute or more.
Report when it completes or fails.

After apply, get the AKS credentials.
Confirm the PostgreSQL endpoint and TLS settings.
Do not assume the new context is active.

If Terraform fails, stop.
Do not run destroy, recreate, or an alternate command without approval.

## AKS Target

Ask for the expected Kubernetes context.
Clarify that the `retagentmgr` namespace is valid for deployment.
Explain and run read-only checks such as:

```bash
kubectl config current-context
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}{"\n"}'
kubectl cluster-info
kubectl auth can-i create deployments -n retagentmgr
kubectl auth can-i create namespaces
```

Report no credentials.
Ask me to confirm the target before a change.

If the target is wrong, stop.
Do not run `kubectl config use-context` without approval.

## Dependencies

Ask me to select `nginx` or `contour`.

First, check namespaces and Helm releases with read-only commands.
If a component exists, report its version and owner.
Ask whether to keep it, reconcile it, or stop.
Cert-manager, trust-manager, and Linkerd must be installed before the ingress and Kueue.

Process components exactly in this order:

1. cert-manager and trust-manager.
2. Linkerd.
3. NGINX or Contour.
4. Kueue.

Apply the Interaction Rules to each change.
After each component, use `helm status`, `kubectl get pods`, and `kubectl wait` as applicable.
Report the release, namespace, and health.
Stop if the component is not healthy.

Copy and edit the example values for NGINX or Contour.
Enter the correct `azure-dns-label-name`, `loadBalancerSourceRanges`, and TLS Secret name.
Do not use only the default values for this deployment.
Match `loadBalancerSourceRanges` to the same value in the `terraform.tfvars` file.

## GPG Keys

GPG keys protect RAM data.
Lost or replaced keys can make data unrecoverable.

Before creation:

1. Check for a RAM Helm release and GPG Secret or ConfigMap. Show names only.
2. Stop if GPG resources exist. Do not replace them.
3. Ask for a secure backup location outside the repository.
4. Confirm the release prefix. The default is `retrieval-agent-manager`.
5. For a custom prefix, set the same value in `security.gpg.nameOverride` after approval.
6. Verify Docker and the current context with read-only commands.

Explain that the helper creates keys, applies AKS resources, and writes files to `scripts/gpg/output`.
Get approval for the exact command:

```bash
# Linux or macOS, from scripts/gpg
./run-bootstrap-gpg.sh

# Windows PowerShell, from scripts/gpg
.\run-bootstrap-gpg.ps1
```

Add `--release <custom-prefix>` for an approved custom prefix.

After completion, verify only that the expected Secret and ConfigMap exist.
Do not read their data.
Require me to back up `scripts/gpg/output` outside the repository.
Require confirmation before installation.

## RAM Values File

Use `examples/ram-values.yaml` as the source.
Propose `./ram-values.yaml` as the output.
Do not use the default chart `values.yaml`.

Get approval before each copy or edit.
Ask for values one at a time.
Before an edit, show the fields that will change.
Give me an example of the expected value.

Configure these groups:

1. **TLS:** `extraObjects[0].data.tls.crt`, `extraObjects[0].data.tls.key`, and the TLS Secret name.
2. **Azure and ingress:** Set `platform` to `azure`. Configure `ingress.domain`, `ingress.enableRootIngress`, and `ingress.classType` as `nginx` or `contour`.
3. **RAM users:** Configure application, Keycloak, monitoring, embedding, PostgREST, migration, OTEL, vectorization job, and vector store accounts.
4. **PostgreSQL:** Configure `users.database.admin.*`, host, port, SSL mode. Keep the existing administrator password separate. A `postgreSQLCertSecret` is not required.
5. **License and IAM:** Configure `api.config.license`, the Keycloak client secret, and the cookie secret.
6. **AKS:** Configure storage, image pull Secret, node selectors, tolerations, and affinity.

I must enter secrets locally.

Ask whether RAM-created accounts will use separate passwords or one shared password.
Explain that separate passwords give better isolation.
Do not apply a shared password to the existing PostgreSQL administrator unless I approve that exact change.

After each approved edit group, run:

```bash
helm lint ./helm/sas-retrieval-agent-manager -f ./ram-values.yaml
```

Do not print secrets.
Continue only after validation and my confirmation of the configuration summary.

## Install and Verify RAM

Before install:

1. Confirm that no RAM Helm release or conflicting resource exists.
2. Confirm that the SAS registry pull Secret and license are available. Do not show their contents.
3. Confirm the GPG resources and backup. For an approved upgrade, retain the existing GPG keys.
4. Confirm all dependencies have been installed. Cert-manager, trust-manager, Linkerd, kueue, and an ingress controller.
4. Run values validation again.
5. Show the release name, chart path, namespace, values file, and expected change.

Use the install command from `README.md`.
Get approval immediately before the command.

Use `helm install` for a new installation.
Use `helm upgrade --install` only for an approved upgrade.

After install, use read-only checks for Helm status, RAM pods, ingress address, and workload scheduling.
Do not show Secret data.

Report the release version, namespace, ready and unready workloads, access address, and remaining manual steps from `docs/azure-deployment.md`.

## Use Docs for Information

* Read `docs/azure-deployment.md` and the applicable `README.md` sections before you give commands.
* Keep all Azure requirements, including PostgreSQL TLS requirements.
* Use the dependency versions, values files, and commands in `README.md` and `docs/user/DependencyInstall.md`.
