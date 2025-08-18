<p align="center">
  <img src="https://github.com/cypik.png" alt="Cypik Logo" width="120"/>
</p>

<h1 align="center">🚀 Terraform Helm Charts — by Cypik</h1>

<p align="center">
  <strong>Modular, Scalable, Production-Ready Kubernetes Deployments</strong><br/>
  Grafana • Loki • Prometheus • KEDA • NGINX • Cert Manager . karpenter . aws-load-balancer-controller. metrics-server . secrets-store-csi-driver
</p>

---

## 🧩 Module Overview

This module is maintained by the **DevOps team at [Cypik](https://github.com/cypik)** to simplify and standardize the deployment of observability and ingress components using Helm and Terraform on Kubernetes.

It includes toggle-able support for:

- ✅ Grafana & Loki
- ✅ Prometheus
- ✅ Cert-Manager
- ✅ NGINX Ingress Controller
- ✅ KEDA

---

## 📦 Usage Example

```hcl
module "helm-charts" {
  source                    = "../../.."
  enable_nginx              = true
  enable_keda               = false
  grafana_enabled           = true
  grafana_loki_enabled      = true
  prometheus_enabled        = true
  cert_manager_enabled      = true
  cert_manager_email        = "admin@cypik.com"
  enabled_karpenter         = true
  alb_ingress_enabled       = false
  enabled_metrics_server    = false
  calico_enabled            = false
  csi_secrets_store_enabled = false
  csi_enabled_namespaces    = ["test"]
  cluster_name              = ""
  vpc_id                    = ""  # vpc_id is required only when ALB Ingress Controller is enabled (alb_ingress_enabled = true)
}

<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name     | Version |
|----------|---------|
| helm     | n/a     |
| null     | n/a     |
| random   | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                     | Type     |
|------------------------------------------------------------------------------------------|----------|
| [helm_release.cert-manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)       | resource |
| [helm_release.grafana](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)            | resource |
| [helm_release.keda](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)               | resource |
| [helm_release.loki](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)               | resource |
| [helm_release.nginx](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)              | resource |
| [helm_release.prometheus](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)         | resource |
| [helm_release.promtail](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)           | resource |
| [null_resource.cert-manager-cluster-issuer](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.grafana_admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name                                | Description                                                                                                      | Type     | Default         | Required |
|-------------------------------------|------------------------------------------------------------------------------------------------------------------|----------|------------------|----------|
| cert_manager_email                  | Your email address to use for cert manager                                                                      | any      | null             | no       |
| cert_manager_enabled                | Enable cert-manager deployment                                                                                  | bool     | false            | no       |
| cert_manager_leader_election_namespace | The namespace used for the leader election lease. Change to cert-manager for GKE Autopilot                   | string   | "cert-manager"   | no       |
| cert_manager_resources              | Resource limits for cert-manager                                                                                | map      | null             | no       |
| cert_manager_version                | Version of the Cert-Manager Helm chart                                                                          | string   | "1.16.3"         | no       |
| cloud_provider                      | Choose between aws or azure                                                                                     | string   | "azure"          | no       |
| datadog_version                     | Datadog Helm chart version                                                                                      | string   | "3.88.3"         | no       |
| enable_grafana                      | Enable Grafana deployment                                                                                       | bool     | true             | no       |
| enable_keda                         | Whether to deploy KEDA                                                                                          | bool     | false            | no       |
| enable_nginx                        | Whether to enable nginx ingress                                                                                 | bool     | true             | no       |
| grafana_admin_password              | Grafana admin password                                                                                          | string   | "Cypik"          | no       |
| grafana_admin_user                  | Grafana admin user                                                                                              | string   | "Cypik"          | no       |
| grafana_chart_version               | Grafana Helm chart version                                                                                      | string   | "7.3.0"          | no       |
| grafana_datasources                 | List of Grafana datasources                                                                                     | list     | []               | no       |
| grafana_efs_enable                  | Enable EFS for Grafana                                                                                          | bool     | false            | no       |
| grafana_efs_storage_class_name      | EFS storage class name                                                                                          | string   | "gp2"            | no       |
| grafana_enabled                     | Enable Grafana                                                                                                  | bool     | false            | no       |
| grafana_extra_yml                   | Extra Grafana configuration                                                                                     | any      | null             | no       |
| grafana_google_auth_client_id       | Google auth client ID                                                                                           | string   | ""               | no       |
| grafana_google_auth_client_secret   | Google auth client secret                                                                                       | string   | ""               | no       |
| grafana_ingress_class_name          | Ingress class name                                                                                              | string   | "nginx"          | no       |
| grafana_ingress_enabled             | Enable Grafana ingress                                                                                          | bool     | false            | no       |
| grafana_ingress_hosts               | Grafana ingress hosts                                                                                           | list     | []               | no       |
| grafana_loki_bucket_name            | Loki S3 bucket name                                                                                             | string   | ""               | no       |
| grafana_loki_container_name         | Loki container name                                                                                             | string   | "jknqwjkdqwkd"   | no       |
| grafana_loki_enabled                | Enable Grafana Loki                                                                                             | bool     | true             | no       |
| grafana_loki_storage_name           | Loki storage name                                                                                               | string   | "jdhdjhd8384839hf" | no     |
| grafana_loki_yml_file               | Loki configuration yaml                                                                                         | any      | null             | no       |
| grafana_name                        | Grafana release name                                                                                            | string   | "grafana"        | no       |
| grafana_persistence_storage         | Enable persistence for Grafana                                                                                  | bool     | true             | no       |
| grafana_values_file                 | Optional values YAML for Grafana                                                                                | string   | null             | no       |
| grafana_version                     | Grafana Helm chart version                                                                                      | string   | "8.8.5"          | no       |
| ingress_nginx_version               | Ingress-NGINX Helm chart version                                                                                | string   | "4.12.1"         | no       |
| keda_chart_version                  | KEDA chart version                                                                                              | string   | "2.13.0"         | no       |
| keda_name                           | KEDA Helm release name                                                                                          | string   | "keda"           | no       |
| keda_namespace                      | KEDA namespace                                                                                                  | string   | "keda"           | no       |
| keda_version                        | KEDA Helm chart version                                                                                         | string   | "2.16.1"         | no       |
| keda_yml_file                       | KEDA values file                                                                                                | string   | null             | no       |
| kubecost_enabled                    | Enable Kubecost                                                                                                 | bool     | false            | no       |
| kubecost_version                    | Kubecost Helm chart version                                                                                     | string   | "2.5.3"          | no       |
| loki_chart_version                  | Loki chart version                                                                                              | string   | "5.43.3"         | no       |
| loki_values_file                    | Loki values file                                                                                                | any      | null             | no       |
| loki_version                        | Loki Helm chart version                                                                                         | string   | "6.25.0"         | no       |
| nginx_max_replicas                  | Max Nginx replicas                                                                                              | number   | 11               | no       |
| nginx_min_replicas                  | Min Nginx replicas                                                                                              | number   | 2                | no       |
| nginx_name                          | Nginx Helm release name                                                                                         | string   | "nginx"          | no       |
| nginx_yml_file                      | Nginx values file                                                                                               | any      | null             | no       |
| opentelemetry_collector_version     | OpenTelemetry Collector chart version                                                                           | string   | "0.115.0"        | no       |
| otel_yml_file                       | OpenTelemetry values file                                                                                       | any      | null             | no       |
| prometheus_additional_scrape_configs | Additional scrape configs for Prometheus                                                                       | list     | []               | no       |
| prometheus_enabled                  | Enable Prometheus                                                                                               | bool     | false            | no       |
| prometheus_persistence_storage      | Enable Prometheus persistence                                                                                   | bool     | false            | no       |
| prometheus_version                  | Prometheus Helm chart version                                                                                   | string   | "27.1.0"         | no       |
| promtail_version                    | Promtail Helm chart version                                                                                     | string   | "6.16.6"         | no       |
| pushgateway_ingress_host            | Prometheus Pushgateway ingress hosts                                                                            | list     | []               | no       |
| storage_class                       | Storage Class                                                                                                   | string   | "managed-csi"    | no       |


<!-- END_TF_DOCS -->
