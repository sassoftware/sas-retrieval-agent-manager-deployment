# EFS Help

In order to create the necessary role, trust policy, and EFS required for RAM, you can follow these commands.

Start by creating the EFS with the following command:

```bash
# Creates the EFS
aws efs create-file-system \
    --creation-token <your-efs-name> \
    --performance-mode generalPurpose \
    --tags Key=Name,Value=RAM_EFS
```

> Note: After creating the EFS, you will have to enable a mount point with DNS for RAM to successfully contact it.

After this, copy [this](../../examples/aws/trust-policy.json) trust-policy into your local directory and apply it to a role with the following command:

```bash
# Creates the Role
aws iam create-role \
    --role-name <RAM-EFS-Driver-Role> \
    --assume-role-policy-document file://trust-policy.json
```

Attach the role policy to the role with the following command:

```bash
# Attaches the Role Policy to the Role
aws iam attach-role-policy \
    --role-name <RAM-EFS-Driver-Role> \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy
```

Finally, attach the EFS role policy to the node-group role:

```bash
aws iam attach-role-policy \ 
    --role-name <Your-Node-Role-ARN> \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy

# Note: You can find your node role ARN by using the following commands
NODE_ROLE_ARN=$(aws iam list-roles --query 'Roles[?RoleName==<your-node-group-name>].Arn' --output text)
echo "Node Role ARN: $NODE_ROLE_ARN"
```

After you create the EFS, Role, and Policy resources in AWS, you can deploy the EFS operator using the following commands:

```bash
# Add the EFS Repository to Helm
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
helm repo update

# Install the EFS Helm chart with your custom values file
helm install aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver -n kube-system -f efs-values.yaml
```

> [Note: you can find an example EFS values file here](../../examples/aws/efs.yaml)

[Back to AWS Deployment Guide](../aws-deployment.md#deploy-rds-ssl-certificate)
