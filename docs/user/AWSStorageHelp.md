# AWS Storage Help

In order to create the necessary role, trust policy, and EFS required for RAM, you can follow these commands.

Start by creating the EFS with the following command:

```bash
# Creates the EFS
aws efs create-file-system \
    --creation-token <your-efs-name> \
    --performance-mode generalPurpose \
    --tags Key=Name,Value=RAM_EFS
```

After this, copy [this](../../examples/aws/trust-policy.json) trust-policy into your local directory and apply it to a role with the following command:

```bash
# Creates the Role
aws iam create-role \
    --role-name <RAM-Storage-Driver-Role> \
    --assume-role-policy-document file://trust-policy.json
```

Attach the role policy to the role with the following command:

```bash
# Attaches the Role Policy to the Role
aws iam attach-role-policy \
    --role-name <RAM-Storage-Driver-Role> \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
```

> Note: `AmazonEBSCSIDriverPolicy` is optional, as it's only used for weaviate

Finally, attach the EFS/EBS role policy to the node-group role:

```bash
aws iam attach-role-policy --role-name <cluster_name_prefix>-default-eks-node-group \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
```

After the EFS is deployed, attach it to a mount target with the appropriate security groups. You can access [more EFS documentation here](https://docs.aws.amazon.com/efs/latest/ug/accessing-fs.html).

## EFS Driver Installation

After you create the EFS, Role, and Policy resources in AWS, and the proper mount target, you can deploy the EFS operator using the following commands:

```bash
# Add the EFS Repository to Helm
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
helm repo update

# Install the EFS Helm chart with your custom values file
helm install aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver -n kube-system -f efs-values.yaml
```

> [Note: you can find an example EFS values file here](../../examples/aws/efs.yaml)

## EBS Driver Installation (optional)

If you want to utilize Weaviate with the AWS deployment of RAM, you'll need the EBS csi driver installed onto your cluster using the following commands:

```bash
# Add the EBS Repository to Helm
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update

# Install the EBS Helm chart with your custom values file
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver -n kube-system -f ebs-values.yaml
```

> [Note: you can find an example EBS values file here](../../examples/aws/ebs.yaml)

[Back to AWS Deployment Guide](../aws-deployment.md#deploy-rds-ssl-certificate)
