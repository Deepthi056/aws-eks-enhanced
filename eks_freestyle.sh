#!/bin/bash
set -euo pipefail

# ----------------------------------------------------
# WARNING: These AWS creds are hard‑coded only for demo.
#           Don’t do this in prod—use Jenkins credentials.
# ----------------------------------------------------
export AWS_ACCESS_KEY_ID="AKIAQ3EGSIFOIO2ON3SX"
export AWS_SECRET_ACCESS_KEY="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"
export AWS_DEFAULT_REGION="us-east-1"

# Validate parameters
for var in CLOUD_TYPE INFRA_NODE_COUNT CORE_NODE_COUNT ACTION CLUSTER_NAME; do
  if [[ -z "${!var:-}" ]]; then
    echo "️  ERROR: Required environment variable '$var' is not set."
    exit 1
  fi
done

echo "-------------------------------------"
echo "Cloud Type:          $CLOUD_TYPE"
echo "Infra Node Count:    $INFRA_NODE_COUNT"
echo "Core Node Count:     $CORE_NODE_COUNT"
echo "Action:              $ACTION"
echo "Cluster Name:        $CLUSTER_NAME"
echo "-------------------------------------"

# Backend parameters
BACKEND_BUCKET="awsdpbucket"
BACKEND_REGION="us-east-1"
BACKEND_KEY="eks-clusters/${CLUSTER_NAME}/terraform.tfstate"

echo "  Using S3 backend key: $BACKEND_KEY"

# Clean out any previous init state
echo " Cleaning old Terraform directories…"
rm -rf .terraform .terraform.lock.hcl

# Re‑initialize Terraform with our dynamic backend
echo "  terraform init -reconfigure -backend-config=\"bucket=$BACKEND_BUCKET\" -backend-config=\"region=$BACKEND_REGION\" -backend-config=\"key=$BACKEND_KEY\""
terraform init -reconfigure \
  -backend-config="bucket=$BACKEND_BUCKET" \
  -backend-config="region=$BACKEND_REGION" \
  -backend-config="key=$BACKEND_KEY"

echo " Backend initialized. State will live at: s3://$BACKEND_BUCKET/$BACKEND_KEY"

# Export TF vars
export TF_VAR_cluster_name="$CLUSTER_NAME"
export TF_VAR_infra_node_count="$INFRA_NODE_COUNT"
export TF_VAR_core_node_count="$CORE_NODE_COUNT"

# Run Terraform
if [[ "$ACTION" == "create" ]]; then
  echo " Running terraform plan…"
  terraform plan -var-file=terraform.tfvars -out=tfplan

  echo " Applying terraform apply…"
  terraform apply -auto-approve tfplan

elif [[ "$ACTION" == "delete" ]]; then
  echo "  Running terraform destroy…"
  terraform destroy -var-file=terraform.tfvars -auto-approve

else
  echo "️  Unknown ACTION: '$ACTION' – must be 'create' or 'delete'"
  exit 1
fi

echo " Terraform $ACTION completed for cluster '$CLUSTER_NAME'."
