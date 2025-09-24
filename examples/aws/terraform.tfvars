# !NOTE! - These are only a subset of CONFIG-VARS.md provided as examples.
# Customize this file to add any variables from 'CONFIG-VARS.md' whose default
# values you want to change.

# ****************  REQUIRED VARIABLES  ****************
# These required variables' values MUST be provided by the User
prefix   = "<prefix-value>"          # this is a prefix that you assign for the resources to be created
location = "<azure-location-value>"  # e.g., "us-east-1", "us-west-2", "eu-west-1"
# ****************  REQUIRED VARIABLES  ****************

# !NOTE! - Without specifying your CIDR block access rules, ingress traffic
#          to your cluster will be blocked by default.

# **************  RECOMMENDED  VARIABLES  ***************
#default_public_access_cidrs = [] # e.g., ["123.45.6.89/32"]
default_public_access_cidrs = []
#ssh_public_key              = "~/.ssh/id_rsa.pub"
# **************  RECOMMENDED  VARIABLES  ***************

# Tags can be specified matching your tagging strategy.
tags = {} # for example: { "owner|email" = "<you>@<domain>.<com>", "key1" = "value1", "key2" = "value2" }

# RDS PostgreSQL Configuration

# Postgres config - By having this entry a database server is created.
#                   Default networking option: Public access (allowed IP addresses) is enabled
#                   If you do not need an external database server remove the 'postgres_servers'
#                   block below.
postgres_servers = {
  default = {
    administrator_login      = "<admin-username>"
    administrator_password   = "<admin-password>"

    # AWS RDS instance class (equivalent to Azure SKU)

    instance_class           = "db.t3.small"     # Equivalent to B_Standard_B2s
    #instance_class          = "db.m5.large"     # Equivalent to GP_Standard_D2ds_v5
    allocated_storage        = 20                # Storage in GB
    max_allocated_storage    = 100               # Auto-scaling limit
    engine_version          = "15.4"             # PostgreSQL version

    # PostgreSQL parameters (equivalent to postgresql_configurations)
    parameter_group_parameters = [
      {
        name  = "shared_preload_libraries"
        value = "pgcrypto,vector"
      }
    ]
    # Database subnet group will be created automatically
    publicly_accessible = true  # Set to false for private access only
  },
}

# Amazon Elastic Container Registry (ECR) config
create_container_registry = false
# ECR doesn't have SKU tiers like Azure ACR - it's pay-per-use
# Admin access is managed through IAM policies instead of a single setting

# EKS (Elastic Kubernetes Service) config
kubernetes_version         = "1.32"
# Node group configuration
default_nodepool_min_nodes = 1
default_nodepool_max_nodes = 5

# AWS EC2 instance type (equivalent to Azure VM type)
default_nodepool_instance_type = "r6in.2xlarge"  # Equivalent to Standard_D16ds_v4
cluster_node_pool_mode     = "minimal"
node_pools = {}

# VPC Configuration (AWS equivalent of Azure VNet)
vpc_cidr = "192.168.0.0/16"

# AWS uses EBS (Elastic Block Store) and EFS (Elastic File System)
storage_type = "standard"

# Options: "none", "ebs-gp3", "ebs-gp2", "efs", "standard"

# EKS Network Configuration
# AWS EKS CNI plugin (equivalent to Azure CNI)
cluster_network_plugin = "aws-vpc-cni"

# Additional AWS-specific variables
# NAT Gateway configuration
enable_nat_gateway = true
single_nat_gateway = false  # Set to true for cost savings in dev environments

# EKS cluster logging
cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

# IRSA (IAM Roles for Service Accounts) - AWS equivalent of Azure Workload Identity
enable_irsa = true

# EKS add-ons
cluster_addons = {
  vpc-cni = {
    version = "latest"
  }
  kube-proxy = {
    version = "latest"
  }
  coredns = {
    version = "latest"
  }
  aws-ebs-csi-driver = {
    version = "latest"
  }
}