terraform {
  backend "s3" {
    # The backend configuration is provided via CLI options.
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources to automatically obtain the default VPC and subnets.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# Data sources to look up IAM roles (ensure these exist in your account).
data "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"
}

data "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"
}

# EKS Cluster Module.
module "eks_cluster" {
  source           = "./modules/eks_cluster"
  cluster_name     = var.cluster_name
  allowed_ssh_cidr = var.allowed_ssh_cidr
  vpc_id           = data.aws_vpc.default.id
  subnet_ids       = data.aws_subnets.default.ids
  cluster_role_arn = data.aws_iam_role.eks_cluster_role.arn
}

# Infra Node Group Module.
module "infrapool" {
  source           = "./modules/node_group"
  cluster_name     = var.cluster_name
  node_group_name  = var.infrapool_name
  desired_capacity = var.infra_node_count
  subnet_ids       = data.aws_subnets.default.ids
  node_role_arn    = data.aws_iam_role.eks_node_role.arn
  instance_type    = var.instance_type
}

# Core Node Group Module.
module "corepool" {
  source           = "./modules/node_group"
  cluster_name     = var.cluster_name
  node_group_name  = var.corepool_name
  desired_capacity = var.core_node_count
  subnet_ids       = data.aws_subnets.default.ids
  node_role_arn    = data.aws_iam_role.eks_node_role.arn
  instance_type    = var.instance_type
}
