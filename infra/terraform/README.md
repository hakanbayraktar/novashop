# NovaShop EKS altyapısı

Bu dizin, NovaShop eğitim ortamı için AWS VPC, iki kullanılabilirlik alanında private EKS node'ları, ECR ve AWS Load Balancer Controller'ı Terraform ile oluşturur. Uygulama bu Terraform katmanıyla değil, ayrı GitHub Actions işindeki Helm komutuyla yayımlanır.

## Oluşturulan kaynaklar

- İki public ve iki private subnet, Internet Gateway ve maliyeti azaltmak için tek NAT Gateway
- EKS `managed node group` (varsayılan iki `t3.small` node)
- Private ve immutable `novashop-ui` ECR deposu; push sonrası image taraması
- EKS OIDC/IRSA ve AWS Load Balancer Controller Helm kurulumu
- ALB için gerekli subnet etiketleri

## Ön koşullar

GitHub Actions, AWS'ye statik access key ile değil OIDC rolüyle bağlanır. Önceden AWS hesabında, yalnız `hakanbayraktar/novashop` reposunun `main` dalı ve `eks-training` environment'ı için güven ilişkisi olan bir IAM rolü oluşturun. Rolün ARN'sini `AWS_ROLE_ARN` secret'ına ekleyin.

Terraform state bucket'ı Terraform çalışmadan önce oluşturulmalıdır; backend kendi bucket'ını oluşturamaz. Örnek:

```bash
aws s3api create-bucket --bucket BENZERSIZ_TF_STATE_BUCKET --region us-east-1
aws s3api put-bucket-versioning --bucket BENZERSIZ_TF_STATE_BUCKET \
  --versioning-configuration Status=Enabled
```

## GitHub ayarları

Repository **Settings → Secrets and variables → Actions** bölümünde:

| Tür | Ad | Değer |
| --- | --- | --- |
| Secret | `AWS_ROLE_ARN` | GitHub OIDC IAM rol ARN'si |
| Variable | `AWS_REGION` | Örn. `us-east-1` |
| Variable | `TF_STATE_BUCKET` | Önceden oluşturulan benzersiz S3 bucket adı |
| Variable | `EKS_CLUSTER_NAME` | Varsayılan: `novashop-training` |

`EKS_CLUSTER_NAME`, `project=novashop` ve `environment=training` değerlerinden gelir. Bu değerleri değiştirirseniz workflow variable'ını da aynı isimle güncelleyin. Pluralsight ortamı büyük instance'lara izin vermediği için varsayılan node tipi `t3.small` seçilmiştir.

## Çalıştırma sırası

1. GitHub Actions'tan **01 - EKS Altyapısı (Terraform)** workflow'unu önce `plan`, sonra `apply` seçeneğiyle çalıştırın.
2. EKS ve ALB Controller hazır olduktan sonra `main` dalına UI değişikliği gönderin veya **02 - NovaShop EKS Uygulama Dağıtımı** workflow'unu elle başlatın.
3. Workflow UI imajını ECR'a gönderir, Helm chart'ı EKS'e uygular ve ALB URL'sini sağlık kontrolüyle doğrular.
4. Eğitim bitince aynı altyapı workflow'unda `destroy` seçeneğini kullanın. EKS, NAT Gateway ve ALB ücretli kaynaklardır.

## Güvenlik notu

EKS API endpoint'i GitHub-hosted runner'ın erişebilmesi için public'tir; erişim IAM/OIDC ile korunur. Gerçek üretim ortamında self-hosted runner'ı VPC içine alıp endpoint erişimini CIDR ile sınırlandırın.
