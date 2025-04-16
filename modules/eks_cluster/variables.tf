variable "cluster_name" {
  description = "Name for the EKS cluster"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed SSH access"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the cluster"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "IAM role ARN for the EKS cluster"
  type        = string
}
