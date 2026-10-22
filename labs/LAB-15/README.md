# LAB-15 — Terraform ile EKS, ALB, Monitoring (ELK & Prometheus) ve GitHub Actions

Bu laboratuvar, NovaShop uygulamasının EKS üzerinde çalıştırılması ve uçtan uca gözlemlenebilirlik (observability) sağlanması için 3 aşamalı bir CI/CD ve GitOps akışı kurar:

1. **`01 - EKS Altyapısı (Terraform)`**: AWS altyapısını, EKS kümesini ve AWS Load Balancer Controller'ı oluşturur.
2. **`02 - NovaShop EKS Uygulama Dağıtımı`**: UI imajını ECR'a gönderir ve Helm ile uygulamayı dağıtır.
3. **`03 - Monitoring & Logging Dağıtımı`**: Prometheus, Grafana, Elasticsearch 9, Logstash, Fluent Bit ve Kibana kurulumlarını yapar; paylaşımlı ALB Ingress ile Cloudflare üzerinden şu domainleri otomatik bağlar:
   - `novashop.devopsatolyesi.com` ➔ NovaShop Web Arayüzü
   - `elk.devopsatolyesi.com` ➔ Kibana Log İzleme
   - `grafana.devopsatolyesi.com` ➔ Grafana Metrik Panelleri
   - `prometheus.devopsatolyesi.com` ➔ Prometheus

İzlenecek kaynak ve değişken detayları: [`infra/terraform/README.md`](../../infra/terraform/README.md).

Eski LAB-13 `eksctl` odaklıdır. Bu laboratuvar ise aynı EKS kavramlarını Terraform state, plan/apply, OIDC ve ECR ile öğretir.
