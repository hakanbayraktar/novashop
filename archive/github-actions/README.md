# Arşivlenmiş GitHub Actions workflow'ları

Bu klasördeki workflow örnekleri eğitimde incelenmek üzere korunur; GitHub Actions yalnız `.github/workflows/` yolunu çalıştırdığı için burada bulunan dosyalar tetiklenmez.

Aktif workflow'lar yalnız şunlardır:

- `01 - EKS Altyapısı (Terraform)`: manuel `plan`, `apply` veya `destroy`
- `02 - NovaShop EKS Uygulama Dağıtımı`: manuel image build, ECR push ve Helm deploy

EC2, ECS, Docker Hub, eski CI ve E2E örnekleri bu klasöre taşınmıştır. Yeniden kullanmak isterseniz dosyayı `.github/workflows/` altına geri alıp gerekli secret ve variable değerlerini tanımlayın.
