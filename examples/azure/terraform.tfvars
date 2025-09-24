# Customize this file to add any variables from 'CONFIG-VARS.md' whose default
# values you want to change.

# ****************  REQUIRED VARIABLES  ****************
# These required variables' values MUST be provided by the User
prefix   = "<prefix-value>" # this is a prefix that you assign for the resources to be created
location = "<azure-location-value>" # e.g., "eastus2"
# ****************  REQUIRED VARIABLES  ****************

# !NOTE! - Without specifying your CIDR block access rules, ingress traffic
#          to your cluster will be blocked by default.

# **************  RECOMMENDED  VARIABLES  ***************
default_public_access_cidrs = [] # e.g., ["123.45.6.89/32"]
# **************  RECOMMENDED  VARIABLES  ***************

# Tags can be specified matching your tagging strategy.
tags = {} # for example: { "owner|email" = "<you>@<domain>.<com>", "key1" = "value1", "key2" = "value2" }

# PostgreSQL

# Postgres config - By having this entry a database server is created.
#                   Default networking option: Public access (allowed IP addresses) is enabled
#                   If you do not need an external database server remove the 'postgres_servers'
#                   block below.
postgres_servers = {
  default = {
# ****************  REQUIRED VARIABLES  ****************
    administrator_login          = "<admin-username>"
    administrator_password       = "<admin-password>"
# ****************  REQUIRED VARIABLES  ***************
    sku_name                     = "GP_Standard_D2ds_v4" # For dev/POC use "B_Standard_B2s", v4 is compatibility, use v5 if available in your region support it.
   # Necessary extensions for RAM to function
    postgresql_configurations    = [
       {
         name  = "azure.extensions"
         value = "PGCRYPTO,VECTOR"
       }
      ]
  },
}


# Azure Container Registry config
create_container_registry           = false
container_registry_sku              = "Standard"
container_registry_admin_enabled    = false


# AKS config
kubernetes_version         = "1.32"

# Small Deployment Defaults
default_nodepool_min_nodes = 1
default_nodepool_max_nodes = 5
default_nodepool_vm_type   = "Standard_E8s_v5"

# Medium Deployment Defaults


aks_network_plugin         = "azure"
aks_network_plugin_mode    = "overlay"
cluster_node_pool_mode     = "minimal"
node_pools                 = {}

# Set following variable to none since CAS/Compute are not in use
# Jump Box
create_jump_vm = false

# Storage for SAS Viya CAS/Compute
storage_type = "none"
