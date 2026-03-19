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

# RDS PostgreSQL Configuration
# Postgres config - By having this entry a database server is created.
#                   Default networking option: Public access (allowed IP addresses) is enabled
#                   If you do not need an external database server remove the 'postgres_servers'
#                   block below.
# Extensions:
#  - PGCRYPTO: Required for basic app functionality
#  - VECTOR:   Optional - Needed if not using weaviate / other vector db solution
postgres_servers = {
  default = {
    administrator_login      = "<admin-username>"
    administrator_password   = "<admin-password>"

    # AWS RDS instance class (equivalent to Azure SKU)

    # Small Deployment DB Size
    instance_type           = "db.m5.large"
    
    # Medium Deployment DB Size
    # instance_type          = "db.m5.xlarge"

    # Large Deployment DB Size
    # instance_type          = "db.m5.2xlarge"

    storage_size            = 20                # Storage in GB
    server_version          = "15.4"             # PostgreSQL version

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
create_jump_vm = false

# EKS (Elastic Kubernetes Service) config
kubernetes_version         = "1.33"
# Node group configuration
default_nodepool_min_nodes = 1
default_nodepool_max_nodes = 5

# AWS EC2 instance type (equivalent to Azure VM type)
default_nodepool_vm_type      = "r6in.2xlarge"  # Equivalent to Standard_D16ds_v4
node_pools = {}

# VPC Configuration (AWS equivalent of Azure VNet)
vpc_cidr = "192.168.0.0/16"

# AWS uses EBS (Elastic Block Store) and EFS (Elastic File System)
storage_type = "standard"

# EKS cluster logging
cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
