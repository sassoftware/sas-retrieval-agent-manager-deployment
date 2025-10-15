# Azure Foundry Connection to RAM

## Introduction

Azure Foundry is an LLM provider in Azure that you will need to allow connectivity from the RAM cluster for it to work properly. Once connection is allowed, you can connect models to query from RAM.

## Allowing a Connection

To allow a connection between RAM and your Azure Foundry resource, the easiest way to do it, is by completing the following steps:

### Retrieve egress IP from your API pod

You can exec into the API pod and perform a `curl ip.me` to retrieve the egress IP to whitelist on the Azure Foundry resource. This can be done using the following commands:

```sh

kubectl exec -it <ram_api_pod> -n retagentmgr -- curl ip.me

# Example output: 15.124.136.98

```

### Whitelist the egress IP on the Azure Foundry Resource

After navigating to the homepage of your Azure Foundry resource, go to the `Networking` tab and add the IP from the previous command under the `Firewall Address Range` section.

## Connection

To connect RAM to the Azure Foundry Resource after you've added the IP address to the firewall whitelist, follow these steps:

- Opening the Settings panel in the top right of the UI
- Selecting the Azure OpenAI model type
- Inserting the desired name and deployment that you have deployed in Azure Foundry
- Inserting your Azure Foundry endpoint into the `URI` field

    > Example: `https://my-azure-foundry-resource.azure.com/`

- Inserting the API key in the `API Key` field

At this point it should be ready to be queried by the user via agents or chat.
