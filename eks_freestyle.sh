#!/bin/bash
set -euo pipefail

export AWS_ACCESS_KEY_ID="AKIAQ3EGSIFOIO2ON3SX"
export AWS_SECRET_ACCESS_KEY="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"
export AWS_DEFAULT_REGION="us-east-1"

# 1) Validate inputs
for var in CLOUD_TYPE INFRA_NODE_COUNT CORE_NODE_COUNT ACTION CLUSTER_NAME; do
  if [[ -z "${!var:-}" ]]; then
    echo " Missing required var: $var"
    exit 1
  fi
done

echo "Initializing Terraform backend…"
terraform init

echo "Selecting workspace '$CLUSTER_NAME'…"
if terraform workspace list | grep -q " ${CLUSTER_NAME}\$"; then
  terraform workspace select "$CLUSTER_NAME"
else
  terraform workspace new "$CLUSTER_NAME"
fi

# Export TF vars
export TF_VAR_cluster_name="$CLUSTER_NAME"
export TF_VAR_infra_node_count="$INFRA_NODE_COUNT"
export TF_VAR_core_node_count="$CORE_NODE_COUNT"

if [[ "$ACTION" == "create" ]]; then
  terraform plan -out=tfplan
  terraform apply -auto-approve tfplan

elif [[ "$ACTION" == "delete" ]]; then
  terraform destroy -auto-approve

else
  echo " Unknown ACTION: $ACTION"
  exit 1
fi
