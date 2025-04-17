#!/bin/bash
set -e

# =====================================================================
# WARNING: Hardcoding AWS credentials is for learning purposes ONLY.
# Do NOT hardcode credentials in production environments.
# =====================================================================
export AWS_ACCESS_KEY_ID="AKIAQ3EGSIFOIO2ON3SX"
export AWS_SECRET_ACCESS_KEY="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"
export AWS_DEFAULT_REGION="us-east-1"

# Validate required parameters passed from the freestyle job.
if [ -z "$CLOUD_TYPE" ]; then
  echo "Error: CLOUD_TYPE is not set. Exiting."
  exit 1
fi

if [ -z "$INFRA_NODE_COUNT" ]; then
  echo "Error: INFRA_NODE_COUNT is not set. Exiting."
  exit 1
fi

if [ -z "$CORE_NODE_COUNT" ]; then
  echo "Error: CORE_NODE_COUNT is not set. Exiting."
  exit 1
fi

if [ -z "$ACTION" ]; then
  echo "Error: ACTION is not set. Exiting."
  exit 1
fi

if [ -z "$CLUSTER_NAME" ]; then
  echo "Error: CLUSTER_NAME is not set. Exiting."
  exit 1
fi

echo "-------------------------------------"
echo "Cloud Type:       $CLOUD_TYPE"
echo "Infra Node Count: $INFRA_NODE_COUNT"
echo "Core Node Count:  $CORE_NODE_COUNT"
echo "Action:           $ACTION"
echo "Cluster Name:     $CLUSTER_NAME"
echo "-------------------------------------"

# Define backend S3 configuration parameters.
BACKEND_BUCKET="awsdpbucket"  # Replace with your existing S3 bucket name (must pre-exist)
BACKEND_REGION="us-east-1"
# Build the tfstate file key using the cluster name.
BACKEND_KEY="eks-clusters/${CLUSTER_NAME}/terraform.tfstate"

# Initialize Terraform (in the current directory, since all files are here).
echo "Initializing backend for ${CLUSTER_NAME}..."
terraform init -reconfigure \
  -backend-config="bucket=awsdpbucket" \
  -backend-config="region=us-east-1" \
  -backend-config="key=eks-clusters/${CLUSTER_NAME}/terraform.tfstate"

# Echo the full S3 path for visibility.
echo "Terraform state file stored at: s3://${BACKEND_BUCKET}/${BACKEND_KEY}"

# Export job parameters as Terraform variables.
export TF_VAR_cluster_name="$CLUSTER_NAME"
export TF_VAR_infra_node_count="$INFRA_NODE_COUNT"
export TF_VAR_core_node_count="$CORE_NODE_COUNT"

# Execute Terraform based on the ACTION parameter.
if [ "$ACTION" == "create" ]; then
    echo "Planning EKS cluster creation..."
    terraform plan -var-file=terraform.tfvars -out=tfplan
    echo "Applying Terraform plan..."
    terraform apply -auto-approve tfplan
elif [ "$ACTION" == "delete" ]; then
    echo "Destroying EKS cluster and its associated node groups..."
    terraform destroy -var-file=terraform.tfvars -auto-approve
else
    echo "Error: ACTION must be 'create' or 'delete'. Exiting."
    exit 1
fi

echo "Terraform execution completed."
