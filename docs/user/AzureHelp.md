---
layout: default
title: Azure help
parent: Azure deployment
grand_parent: Deployment
nav_order: 1
---

# Azure help

## Tenant ID and Subscription ID

You can use the following commands, or alter them as needed to set the environment variables with your Tenant ID and Subscription:

Linux/macOS (Bash)

```bash
az login

# Set the tenant ID from a query; validate
TF_VAR_tenant_id=$(az account show --query 'tenantId' --output tsv)
echo $TF_VAR_tenant_id

# Set the subscription ID from a query; validate
TF_VAR_subscription_id=$(az account show --query 'id' --output tsv)
echo $TF_VAR_subscription_id
```

Windows (PowerShell)

```powershell
az login

# Set the tenant ID from a query; validate
$env:TF_VAR_tenant_id = az account show --query 'tenantId' --output tsv
Write-Output $env:TF_VAR_tenant_id

# Set the subscription ID from a query; validate
$env:TF_VAR_subscription_id = az account show --query 'id' --output tsv
Write-Output $env:TF_VAR_subscription_id
```

## Client ID and Client Secret

To deploy using this method, you need a Service Principal.

A Service Principal is an Azure identity for an application. Terraform uses this identity to access
Azure resources.

Enter a unique name for the Service Principal. The commands get the client ID and client secret
from the Service Principal creation result. The commands do not use the name of your signed-in
user.

Linux/macOS (Bash)

```bash
az login

# Get and validate the active subscription ID
if ! TF_VAR_subscription_id=$(az account show --query id --output tsv) || \
	[[ -z "$TF_VAR_subscription_id" ]]; then
	printf 'Azure CLI did not return a subscription ID.\n' >&2
else
	export TF_VAR_subscription_id
	printf 'Subscription ID: %s\n' "$TF_VAR_subscription_id"

	# Enter a new, unique Service Principal name
	printf 'Service Principal name: '
	IFS= read -r service_principal_name

	if [[ -z "$service_principal_name" ]]; then
		printf 'The Service Principal name is required.\n' >&2
	elif service_principal_credentials=$(az ad sp create-for-rbac \
		--name "$service_principal_name" \
		--role "Contributor" \
		--scopes "/subscriptions/$TF_VAR_subscription_id" \
		--query '[appId,password]' \
		--output tsv); then
		TF_VAR_client_id=${service_principal_credentials%%$'\t'*}
		TF_VAR_client_secret=${service_principal_credentials#*$'\t'}
		export TF_VAR_client_id TF_VAR_client_secret

		# Verify the Client ID. Do not print the Client Secret.
		printf 'Client ID: %s\n' "$TF_VAR_client_id"
	else
		printf 'Azure did not create the Service Principal.\n' >&2
	fi
fi
```

Windows (PowerShell)

```powershell
az login

# Get and validate the active subscription ID
$env:TF_VAR_subscription_id = az account show --query id --output tsv
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($env:TF_VAR_subscription_id)) {
	throw "Azure CLI did not return a subscription ID."
}
Write-Output "Subscription ID: $env:TF_VAR_subscription_id"

# Enter a unique Service Principal name
$servicePrincipalName = Read-Host "Service Principal name"
if ([string]::IsNullOrWhiteSpace($servicePrincipalName)) {
	throw "The Service Principal name is required."
}

# Create the Service Principal
$servicePrincipalJson = az ad sp create-for-rbac `
	--name $servicePrincipalName `
	--role "Contributor" `
	--scopes "/subscriptions/$env:TF_VAR_subscription_id" `
	--query "{clientId:appId,clientSecret:password}" `
	--output json
if ($LASTEXITCODE -ne 0) {
	throw "Azure did not create the Service Principal."
}
$servicePrincipal = $servicePrincipalJson | ConvertFrom-Json

# Set the Terraform environment variables
$env:TF_VAR_client_id = $servicePrincipal.clientId
$env:TF_VAR_client_secret = $servicePrincipal.clientSecret

# Verify the Client ID. Do not print the Client Secret.
Write-Output "Client ID: $env:TF_VAR_client_id"
```

## Notes

- You will need an Azure account with an 'Owner' role to perform these operations
- The Service Principal name must be unique
- If Azure finds an existing application, enter a different Service Principal name.
- Ask your Microsoft Entra administrator for permission if Azure reports `Insufficient privileges to complete the operation`.
- For Windows Command Prompt, double quotes are used around values that might contain spaces
- PowerShell uses `$env:` prefix for environment variables, while Command Prompt uses `%` around variable names
- Store the client secret in a secure location. Azure does not show this value again.
