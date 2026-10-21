# LAB-15 — Terraform ile EKS, ALB ve GitHub Actions

Bu laboratuvar, NovaShop uygulamasının EKS üzerinde çalıştırılması için iki katmanlı bir CI/CD akışı kurar.

1. Terraform, AWS altyapısını ve AWS Load Balancer Controller'ı oluşturur.
2. GitHub Actions, UI imajını ECR'a yollar ve Helm ile yalnız uygulama sürümünü günceller.

İzlenecek kaynak: [`infra/terraform/README.md`](../../infra/terraform/README.md).

Eski LAB-13 `eksctl` odaklıdır. Bu laboratuvar ise aynı EKS kavramlarını Terraform state, plan/apply, OIDC ve ECR ile öğretir.
