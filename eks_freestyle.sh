#!/bin/bash
set -euo pipefail

# ------------------------------------------------
# WARNING: Hardcoding AWS creds is for demo only.
# ------------------------------------------------
export AWS_ACCESS_KEY_ID="AKIAQ3EGSIFOIO2ON3SX"
export AWS_SECRET_ACCESS_KEY="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"
export AWS_DEFAULT_REGION="us-east-1"

# 1) Validate inputs
for v in CLOUD_TYPE INFRA_NODE_COUNT CORE_NODE_COUNT ACTION CLUSTER_NAME; do
  if [[ -z "${!v:-}" ]]; then
    echo " Missing required var: $v"
    exit 1
  fi
done

echo "  Cloud Type:          $CLOUD_TYPE"
echo "  Infra Nodes:         $INFRA_NODE_COUNT"
echo "  Core Nodes:          $CORE_NODE_COUNT"
echo "  Action:              $ACTION"
echo "  Cluster Name:        $CLUSTER_NAME"

# 2) Backend config
BUCKET="awsdpbucket"
REGION="us-east-1"
KEY="eks-clusters/${CLUSTER_NAME}/terraform.tfstate"

echo " Using S3 state: s3://$BUCKET/$KEY"

# 3) Ensure you have in your main.tf:
#    terraform { backend "s3" {} }
grep -Rq 'backend "s3" {}' main.tf || {
  echo " main.tf is missing: terraform { backend \"s3\" {} }"
  exit 1
}

# 4) Clean any prior init metadata
echo " Cleaning .terraform/ and lock file…"
rm -rf .terraform .terraform.lock.hcl

# 5) Init with both migrate-state and reconfigure
echo "  terraform init -migrate-state -reconfigure \\"
echo "    -backend-config=\"bucket=$BUCKET\" \\"
echo "    -backend-config=\"region=$REGION\" \\"
echo "    -backend-config=\"key=$KEY\""
terraform init -migrate-state -reconfigure \
  -backend-config="bucket=$BUCKET" \
  -backend-config="region=$REGION" \
  -backend-config="key=$KEY"

# 6) Export TF vars
export TF_VAR_cluster_name="$CLUSTER_NAME"
export TF_VAR_infra_node_count="$INFRA_NODE_COUNT"
export TF_VAR_core_node_count="$CORE_NODE_COUNT"

# 7) Plan or destroy
if [[ "$ACTION" == "create" ]]; then
  echo " terraform plan…"
  terraform plan -var-file=terraform.tfvars -out=tfplan

  echo " terraform apply…"
  terraform apply -auto-approve tfplan

elif [[ "$ACTION" == "delete" ]]; then
  echo " terraform destroy…"
  terraform destroy -var-file=terraform.tfvars -auto-approve

else
  echo " Unknown ACTION: $ACTION"
  exit 1
fi

echo " DONE: $ACTION cluster $CLUSTER_NAME"
