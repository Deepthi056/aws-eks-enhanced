variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name for the EKS cluster"
  type        = string
}

variable "infra_node_count" {
  description = "Number of nodes for the infrapool node group"
  type        = number
}

variable "core_node_count" {
  description = "Number of nodes for the corepool node group"
  type        = number
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed SSH access (typically your public IP)"
  type        = string
  default     = "49.207.235.217/32"
}

variable "instance_type" {
  description = "EC2 instance type for the node groups"
  type        = string
  default     = "t2.micro"
}

variable "infrapool_name" {
  description = "Name for the infrapool node group"
  type        = string
  default     = "infrapool"
}

variable "corepool_name" {
  description = "Name for the corepool node group"
  type        = string
  default     = "corepool"
}
