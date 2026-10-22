# LAB-15 — Terraform ile EKS, ALB, Monitoring (ELK & Prometheus) ve GitHub Actions

Bu laboratuvar, NovaShop uygulamasının AWS EKS üzerinde çalıştırılması ve uçtan uca gözlemlenebilirlik (Observability - Metrics, Logs, Traces & Alerts) sağlanması için 3 aşamalı bir CI/CD ve GitOps akışı kurar:

1. **`01 - EKS Altyapısı (Terraform)`**: AWS VPC, EKS kümesi (`t3.medium` worker nodelar) ve AWS Load Balancer Controller bileşenlerini oluşturur.
2. **`02 - NovaShop EKS Uygulama Dağıtımı`**: UI imajını AWS ECR'a gönderir ve Helm ile mikroservisleri (`novashop` namespace) dağıtır.
3. **`03 - Monitoring & Logging Dağıtımı`**: Prometheus, Grafana, Elasticsearch 9, Logstash, Fluent Bit ve Kibana kurulumlarını yapar; paylaşımlı ALB Ingress ile Cloudflare üzerinden şu domainleri otomatik bağlar:
   - `http://novashop.devopsatolyesi.com` ➔ NovaShop Web Mağaza Arayüzü
   - `http://elk.devopsatolyesi.com` ➔ Kibana Log İzleme & Arama
   - `http://grafana.devopsatolyesi.com` ➔ Grafana Metrik Panelleri & Alerting (Kullanıcı: `admin` / Parola: `devops2026`)
   - `http://prometheus.devopsatolyesi.com` ➔ Prometheus Metrik ve Alarm Arayüzü

---

## 📊 Kurulu Kurulmaz Hazır Gelen Raporlar ve Paneller (Out-of-the-Box)

Grafana ve Kibana sistem kurulduğu anda hiçbir manuel işlem yapılmasına gerek kalmadan aşağıdaki hazır raporlarla açılır:

### 1. Grafana Hazır Panelleri (Otomatik Provisioned)
Grafana'ya giriş yaptıktan sonra **Dashboards ➔ Browse (veya NovaShop klasörü)** altında 3 ana panel hazır durumdadır:

1. **`Kubernetes — EKS Cluster & Node Metrics` (UID: `k8s-cluster-nodes`)**:
   - **Cluster Özeti:** Toplam Node Sayısı, vCPU Çekirdek Havuzu, Toplam RAM, Küme ortalama CPU ve Bellek kullanım oranları (%).
   - **Node Detayları & Trendler:** Node bazında anlık CPU (vCPU & %), Bellek (Working Set & %) ve Ağ (RX/TX bant genişliği) zaman serisi grafikleri.
   - **Alarm Durumu:** Kümedeki anlık aktif/firing Prometheus alarmlarının canlı sayacı.
2. **`Kubernetes — Pods & Containers Resource Metrics` (UID: `k8s-pods-containers`)**:
   - **Dinamik Filtreler:** `$namespace` (novashop, logging, monitoring, kube-system) ve `$pod` seçicileri.
   - **Pod Kaynak Kullanımı:** Seçili podların CPU tüketimi (Cores), Bellek kullanımı (MB/GB), Ağ trafiği (Bps).
3. **`NovaShop — Microservices RED & Business Overview` (UID: `novashop-services-overview`)**:
   - **İş Metrikleri:** Toplam Checkout denemeleri, Başarılı/Başarısız sipariş sayıları.
   - **RED Metrikleri:** Rate (istek sıklığı), Errors (HTTP 5xx hata oranı) ve Duration (p99 latency).

---

## 🚨 Prometheus Hazır Alarm Kuralları (Active Alert Rules)

Prometheus, EKS Kubelet ve NovaShop mikroservislerini sürekli tarar ve aşağıdaki kurallar otomatik devrededir:

| Alarm Adı | Koşul | Şiddet | Açıklama |
|---|---|---|---|
| **NodeHighCpuUsage** | Node CPU kullanımı > %85 (3 dakika boyunca) | `warning` | Worker node CPU doygunluğu |
| **NodeHighMemoryUsage** | Node Bellek kullanımı > %85 (3 dakika boyunca) | `warning` | Worker node RAM doygunluğu |
| **KubeletScrapeDown** | Kubelet erişilemiyor | `critical` | Node seviyesinde metrik kesintisi |
| **ContainerHighMemoryUsage** | Konteyner RAM'i limitin %90'ını aştı | `warning` | OOMKilled riskini önceden haber verir |
| **NovaShopServiceDown** | `up{job="novashop-services"} == 0` | `critical` | NovaShop podu çöktü veya erişilemiyor |

---

## 🪵 Kibana Hazır Log Görünümü (Data View)

- Fluent Bit tüm Kubernetes loglarını toplar, Logstash pipeline'ından geçirerek Elasticsearch 9'a `k8s-logs-*` indeksiyle yazar.
- Kibana'da **`Kubernetes Logs` (`k8s-logs-*`)** Data View otomatik oluşturulmuş ve varsayılan olarak ayarlanmıştır.
- `http://elk.devopsatolyesi.com` adresini açıp doğrudan sol menüdeki **Discover** sekmesine tıkladığınızda tüm pod logları hazır filtrelenebilir şekilde listelenir.

---

## 🎯 Grafana'ya Manuel Eklenebilecek Popüler Topluluk Raporları (Community Dashboards)

Eğer kümenize ek olarak hazır topluluk şablonları eklemek isterseniz, aşağıdaki popüler Grafana Dashboard ID'lerini kullanabilirsiniz:

| Dashboard Adı | Grafana ID | Doğrudan Link | Açıklama |
|---|---|---|---|
| **Kubernetes cluster monitoring (cAdvisor)** | `315` | [grafana.com/dashboards/315](https://grafana.com/grafana/dashboards/315/) | cAdvisor üzerinden detaylı küme ve konteyner metrikleri |
| **Kubernetes Cluster (Prometheus)** | `6417` | [grafana.com/dashboards/6417](https://grafana.com/grafana/dashboards/6417/) | Küme seviyesinde pod, daemonset ve deployment görünümü |
| **Node Exporter Full** | `1860` | [grafana.com/dashboards/1860](https://grafana.com/grafana/dashboards/1860/) | Linux OS seviyesinde disk I/O, CPU, network detayları |
| **JVM (Micrometer)** | `4701` | [grafana.com/dashboards/4701](https://grafana.com/grafana/dashboards/4701/) | Spring Boot (NovaShop Java servisleri) JVM Heap & GC metrikleri |
| **Kubernetes Pods Resource Usage** | `15757` | [grafana.com/dashboards/15757](https://grafana.com/grafana/dashboards/15757/) | Pod bazında CPU/RAM limit ve request karşılaştırmaları |

### 🛠️ Grafana UI Üzerinden Manuel Dashboard İçe Aktarma Adımları:
1. Grafana arayüzüne giriş yapın (`http://grafana.devopsatolyesi.com`).
2. Sol menüden **Dashboards** simgesine tıklayın.
3. Sağ üstteki mavi **New** butonuna basıp **Import** seçeneğini seçin.
4. **"Import via grafana.com"** kutusuna yukarıdaki ID'lerden birini girin (Örn: `315` veya `15757`) ve **Load** butonuna tıklayın.
5. Veri kaynağı (Prometheus) alanında **Prometheus**'u seçip **Import** butonuna basın. Paneliniz anında kullanıma hazır olacaktır!
