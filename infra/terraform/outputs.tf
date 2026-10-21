output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_region" {
  value = var.aws_region
}

output "ecr_ui_repository_url" {
  value = aws_ecr_repository.ui.repository_url
}
