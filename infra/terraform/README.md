# NovaShop EKS altyapısı

Bu dizin, NovaShop eğitim ortamı için AWS VPC, iki kullanılabilirlik alanında private EKS node'ları, ECR ve AWS Load Balancer Controller'ı Terraform ile oluşturur. Uygulama bu Terraform katmanıyla değil, ayrı GitHub Actions işindeki Helm komutuyla yayımlanır.

## Oluşturulan kaynaklar

- İki public ve iki private subnet, Internet Gateway ve maliyeti azaltmak için tek NAT Gateway
- EKS `managed node group` (varsayılan iki `t3.small` node)
- Private ve immutable `novashop-ui` ECR deposu; push sonrası image taraması
- EKS OIDC/IRSA ve AWS Load Balancer Controller Helm kurulumu
- ALB için gerekli subnet etiketleri

## 0. Zorunlu ön hazırlık: Terraform state bucket'ı

Terraform state bucket'ı **Terraform workflow'undan önce** oluşturulmalıdır; S3 backend, henüz mevcut olmayan kendi bucket'ını oluşturamaz. Aşağıdaki örnek varsayılan `us-east-1` bölgesi içindir. Bucket adı AWS genelinde benzersiz olmalıdır.

```bash
export AWS_REGION=us-east-1
export TF_STATE_BUCKET=benzersiz-novashop-tf-state-ACCOUNT_ID

aws s3api create-bucket --bucket "$TF_STATE_BUCKET" --region "$AWS_REGION"
aws s3api put-bucket-versioning --bucket "$TF_STATE_BUCKET" \
  --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket "$TF_STATE_BUCKET" \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
aws s3api put-public-access-block --bucket "$TF_STATE_BUCKET" \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

`us-east-1` dışında bir bölge kullanırsanız `create-bucket` komutuna ilgili `LocationConstraint` eklenmelidir. Oluşturduğunuz bucket adını GitHub'da `TF_STATE_BUCKET` variable'ına girin. Workflow state'i `novashop/eks/terraform.tfstate` anahtarında, S3 native lockfile ile kilitli tutar.

## 1. Diğer ön koşullar

Bu eğitim akışı Pluralsight AWS laboratuvarı için GitHub Secrets'taki erişim anahtarlarıyla çalışır. Terraform'u ilk çalıştıran IAM kullanıcısı EKS cluster administrator erişimini alır; uygulama deploy workflow'u da aynı anahtarlarla bağlandığı için `kubectl` ve Helm kullanabilir.

## 2. GitHub ayarları

Repository **Settings → Secrets and variables → Actions** bölümünde:

| Tür | Ad | Değer |
| --- | --- | --- |
| Secret | `AWS_ACCESS_KEY_ID` | Pluralsight IAM kullanıcısının access key değeri |
| Secret | `AWS_SECRET_ACCESS_KEY` | Pluralsight IAM kullanıcısının secret access key değeri |
| Variable | `AWS_REGION` | Örn. `us-east-1` |
| Variable | `TF_STATE_BUCKET` | Önceden oluşturulan benzersiz S3 bucket adı |
| Variable | `EKS_CLUSTER_NAME` | Varsayılan: `novashop-training` |

`EKS_CLUSTER_NAME`, `project=novashop` ve `environment=training` değerlerinden gelir. Bu değerleri değiştirirseniz workflow variable'ını da aynı isimle güncelleyin. Pluralsight ortamı büyük instance'lara izin vermediği için varsayılan node tipi `t3.small` seçilmiştir.

## 3. Çalıştırma sırası

1. GitHub Actions'tan **01 - EKS Altyapısı (Terraform)** workflow'unu önce `plan`, sonra `apply` seçeneğiyle çalıştırın.
2. EKS ve ALB Controller hazır olduktan sonra `main` dalına UI değişikliği gönderin veya **02 - NovaShop EKS Uygulama Dağıtımı** workflow'unu elle başlatın.
3. Workflow UI imajını ECR'a gönderir, Helm chart'ı EKS'e uygular ve ALB URL'sini sağlık kontrolüyle doğrular.
4. Eğitim bitince aynı altyapı workflow'unda `destroy` seçeneğini kullanın. EKS, NAT Gateway ve ALB ücretli kaynaklardır.

## Güvenlik notu

EKS API endpoint'i GitHub-hosted runner'ın erişebilmesi için public'tir; erişim IAM ile korunur. Bu access key yaklaşımı eğitim içindir. Gerçek üretim ortamında GitHub OIDC, sınırlı IAM rolü, self-hosted runner ve CIDR ile sınırlandırılmış endpoint kullanın.
