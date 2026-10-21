variable "aws_region" {
  description = "AWS region in which the EKS cluster is created."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Short project name used in AWS resource names."
  type        = string
  default     = "novashop"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "training"
}

variable "kubernetes_version" {
  description = "An EKS version currently in standard support."
  type        = string
  default     = "1.37"
}

variable "node_instance_type" {
  description = "EKS managed-node-group instance type."
  type        = string
  default     = "t3.small"
}
