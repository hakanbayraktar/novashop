output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_region" {
  value = var.aws_region
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "aws_load_balancer_controller_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller"
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

output "ecr_ui_repository_url" {
  value = aws_ecr_repository.ui.repository_url
}
