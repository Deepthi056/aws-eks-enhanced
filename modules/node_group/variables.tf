variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "node_group_name" {
  description = "Name for the node group (e.g., 'infrapool' or 'corepool')"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of nodes for the node group"
  type        = number
}

variable "subnet_ids" {
  description = "List of subnet IDs for the node group"
  type        = list(string)
}

variable "node_role_arn" {
  description = "IAM role ARN for the node group"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the nodes in the group"
  type        = string
}
