# Azure Help

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

To deploy using this method, you'll need a Service Principal.

A Service Principal is effectively a "user" that you create in order to enable automated tools, like Terraform, to access Azure services on your behalf. You give it a role with only the permissions needed to execute the tasks that the Service Principal performs on your behalf.

You can create a Service Principal to use with Terraform by taking the following steps:

Linux/macOS (Bash)

```bash
az login

# Set the Client Secret from a query; validate
TF_VAR_client_secret=$(az ad sp create-for-rbac --role "Contributor" --scopes="/subscriptions/$TF_VAR_subscription_id" --name http://$USER --query password --output tsv)
echo $TF_VAR_client_secret

# Set the Client ID from a query; validate
TF_VAR_client_id=$(az ad sp list --display-name http://$USER --query [].appId --output tsv)
echo $TF_VAR_client_id
```

Windows (PowerShell)

```powershell
az login

# Set the Client Secret from a query; validate
$env:TF_VAR_client_secret = az ad sp create-for-rbac --role "Contributor" --scopes="/subscriptions/$env:TF_VAR_subscription_id" --name "http://$env:USERNAME" --query password --output tsv
Write-Output $env:TF_VAR_client_secret

# Set the Client ID from a query; validate
$env:TF_VAR_client_id = az ad sp list --display-name "http://$env:USERNAME" --query [].appId --output tsv
Write-Output $env:TF_VAR_client_id
```

## Notes

- You will need an Azure account with an 'Owner' role to perform these operations
- The Service Principal name must be unique
- For Windows Command Prompt, double quotes are used around values that might contain spaces
- PowerShell uses `$env:` prefix for environment variables, while Command Prompt uses `%` around variable names
- The `$USER` variable in Linux/macOS is equivalent to `$env:USERNAME` in PowerShell and `%USERNAME%` in Command Prompt
