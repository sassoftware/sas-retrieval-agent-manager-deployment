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

# Enter a unique Service Principal name
read -r -p "Service Principal name: " service_principal_name

# Create the Service Principal and set the Terraform environment variables
IFS=$'\t' read -r TF_VAR_client_id TF_VAR_client_secret < <(
	az ad sp create-for-rbac \
		--name "$service_principal_name" \
		--role "Contributor" \
		--scopes "/subscriptions/$TF_VAR_subscription_id" \
		--query '[appId,password]' \
		--output tsv
)
export TF_VAR_client_id TF_VAR_client_secret

# Verify the Client ID. Do not print the Client Secret.
printf 'Client ID: %s\n' "$TF_VAR_client_id"
```

Windows (PowerShell)

```powershell
az login

# Enter a unique Service Principal name
$servicePrincipalName = Read-Host "Service Principal name"

# Create the Service Principal
$servicePrincipal = az ad sp create-for-rbac `
	--name $servicePrincipalName `
	--role "Contributor" `
	--scopes "/subscriptions/$env:TF_VAR_subscription_id" `
	--query "{clientId:appId,clientSecret:password}" `
	--output json | ConvertFrom-Json

# Set the Terraform environment variables
$env:TF_VAR_client_id = $servicePrincipal.clientId
$env:TF_VAR_client_secret = $servicePrincipal.clientSecret

# Verify the Client ID. Do not print the Client Secret.
Write-Output "Client ID: $env:TF_VAR_client_id"
```

## Notes

- You will need an Azure account with an 'Owner' role to perform these operations
- The Service Principal name must be unique
- For Windows Command Prompt, double quotes are used around values that might contain spaces
- PowerShell uses `$env:` prefix for environment variables, while Command Prompt uses `%` around variable names
- Store the client secret in a secure location. Azure does not show this value again.
