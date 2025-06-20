<p align="center">
  <img src="https://github.com/cypik.png" alt="Cypik Logo" width="120"/>
</p>

<h1 align="center">🚀 Terraform Helm Charts — by Cypik</h1>

<p align="center">
  <strong>Modular, Scalable, Production-Ready Kubernetes Deployments</strong><br/>
  Grafana • Loki • Prometheus • KEDA • NGINX • Cert Manager
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
  source                = "../../.."
  enable_nginx          = true
  enable_keda           = false
  grafana_enabled       = true
  grafana_loki_enabled  = true
  prometheus_enabled    = true
  cert_manager_enabled  = true
  cert_manager_email    = "admin@cypik.com"
}

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.cert-manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.grafana](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.keda](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.loki](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.nginx](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.prometheus](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.promtail](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [null_resource.cert-manager-cluster-issuer](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.grafana_admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cert_manager_email"></a> [cert\_manager\_email](#input\_cert\_manager\_email) | Your email address to use for cert manager | `any` | `null` | no |
| <a name="input_cert_manager_enabled"></a> [cert\_manager\_enabled](#input\_cert\_manager\_enabled) | Enable cert-manager deployment | `bool` | `false` | no |
| <a name="input_cert_manager_leader_election_namespace"></a> [cert\_manager\_leader\_election\_namespace](#input\_cert\_manager\_leader\_election\_namespace) | The namespace used for the leader election lease. Change to cert-manager for GKE Autopilot | `string` | `"cert-manager"` | no |
| <a name="input_cert_manager_resources"></a> [cert\_manager\_resources](#input\_cert\_manager\_resources) | n/a | <pre>map(object({<br>    cpu    = string<br>    memory = string<br>  }))</pre> | `null` | no |
| <a name="input_cert_manager_version"></a> [cert\_manager\_version](#input\_cert\_manager\_version) | The version of the Cert-Manager Helm chart to be deployed, used for automating the issuance and renewal of TLS certificates. | `string` | `"1.16.3"` | no |
| <a name="input_cloud_provider"></a> [cloud\_provider](#input\_cloud\_provider) | Choose between aws or azure | `string` | `"azure"` | no |
| <a name="input_datadog_version"></a> [datadog\_version](#input\_datadog\_version) | The version of the Datadog Helm chart to be deployed, used for monitoring, security, and observability in Kubernetes environments. | `string` | `"3.88.3"` | no |
| <a name="input_enable_grafana"></a> [enable\_grafana](#input\_enable\_grafana) | Enable Grafana deployment | `bool` | `true` | no |
| <a name="input_enable_keda"></a> [enable\_keda](#input\_enable\_keda) | Whether to deploy KEDA | `bool` | `false` | no |
| <a name="input_enable_nginx"></a> [enable\_nginx](#input\_enable\_nginx) | Whether to enable nginx ingress | `bool` | `true` | no |
| <a name="input_grafana_admin_password"></a> [grafana\_admin\_password](#input\_grafana\_admin\_password) | The Password of Grafana for login Dashboard | `string` | `"Cypik"` | no |
| <a name="input_grafana_admin_user"></a> [grafana\_admin\_user](#input\_grafana\_admin\_user) | The User name of Grafana for login Dashboard | `string` | `"Cypik"` | no |
| <a name="input_grafana_chart_version"></a> [grafana\_chart\_version](#input\_grafana\_chart\_version) | Grafana Helm chart version | `string` | `"7.3.0"` | no |
| <a name="input_grafana_datasources"></a> [grafana\_datasources](#input\_grafana\_datasources) | n/a | <pre>list(object({<br>    name      = string<br>    type      = string<br>    url       = string<br>    access    = string<br>    isDefault = bool<br>  }))</pre> | `[]` | no |
| <a name="input_grafana_efs_enable"></a> [grafana\_efs\_enable](#input\_grafana\_efs\_enable) | Enable EFS storage for Grafana | `bool` | `false` | no |
| <a name="input_grafana_efs_storage_class_name"></a> [grafana\_efs\_storage\_class\_name](#input\_grafana\_efs\_storage\_class\_name) | If EFS is needed pass EFS storage class, but make sure efs and efs driver deployed | `string` | `"gp2"` | no |
| <a name="input_grafana_enabled"></a> [grafana\_enabled](#input\_grafana\_enabled) | Enable grafana | `bool` | `false` | no |
| <a name="input_grafana_extra_yml"></a> [grafana\_extra\_yml](#input\_grafana\_extra\_yml) | Grafana Datasources as Yaml | `any` | `null` | no |
| <a name="input_grafana_google_auth_client_id"></a> [grafana\_google\_auth\_client\_id](#input\_grafana\_google\_auth\_client\_id) | Add Google Auth client id | `string` | `""` | no |
| <a name="input_grafana_google_auth_client_secret"></a> [grafana\_google\_auth\_client\_secret](#input\_grafana\_google\_auth\_client\_secret) | Add Google Auth client secret | `string` | `""` | no |
| <a name="input_grafana_ingress_class_name"></a> [grafana\_ingress\_class\_name](#input\_grafana\_ingress\_class\_name) | Ingress class name for Grafana | `string` | `"nginx"` | no |
| <a name="input_grafana_ingress_enabled"></a> [grafana\_ingress\_enabled](#input\_grafana\_ingress\_enabled) | Enable grafana ingress | `bool` | `false` | no |
| <a name="input_grafana_ingress_hosts"></a> [grafana\_ingress\_hosts](#input\_grafana\_ingress\_hosts) | Add grafana ingress hosts | `list` | `[]` | no |
| <a name="input_grafana_loki_bucket_name"></a> [grafana\_loki\_bucket\_name](#input\_grafana\_loki\_bucket\_name) | Name for the S3 bucket | `string` | `""` | no |
| <a name="input_grafana_loki_container_name"></a> [grafana\_loki\_container\_name](#input\_grafana\_loki\_container\_name) | n/a | `string` | `"jknqwjkdqwkd"` | no |
| <a name="input_grafana_loki_enabled"></a> [grafana\_loki\_enabled](#input\_grafana\_loki\_enabled) | Enable grafana loki | `bool` | `true` | no |
| <a name="input_grafana_loki_storage_name"></a> [grafana\_loki\_storage\_name](#input\_grafana\_loki\_storage\_name) | n/a | `string` | `"jdhdjhd8384839hf"` | no |
| <a name="input_grafana_loki_yml_file"></a> [grafana\_loki\_yml\_file](#input\_grafana\_loki\_yml\_file) | n/a | `any` | `null` | no |
| <a name="input_grafana_name"></a> [grafana\_name](#input\_grafana\_name) | Name of the Grafana release | `string` | `"grafana"` | no |
| <a name="input_grafana_persistence_storage"></a> [grafana\_persistence\_storage](#input\_grafana\_persistence\_storage) | Enable persistence storage for Grafana | `bool` | `true` | no |
| <a name="input_grafana_values_file"></a> [grafana\_values\_file](#input\_grafana\_values\_file) | Optional values YAML file for Grafana | `string` | `null` | no |
| <a name="input_grafana_version"></a> [grafana\_version](#input\_grafana\_version) | The version of the Grafana Helm chart to be deployed, used for data visualization and monitoring dashboards. | `string` | `"8.8.5"` | no |
| <a name="input_ingress_nginx_version"></a> [ingress\_nginx\_version](#input\_ingress\_nginx\_version) | The version of the Ingress-NGINX Helm chart to be deployed, used for managing ingress traffic in Kubernetes. | `string` | `"4.12.1"` | no |
| <a name="input_keda_chart_version"></a> [keda\_chart\_version](#input\_keda\_chart\_version) | Version of the KEDA chart | `string` | `"2.13.0"` | no |
| <a name="input_keda_name"></a> [keda\_name](#input\_keda\_name) | Name of the Helm release for KEDA | `string` | `"keda"` | no |
| <a name="input_keda_namespace"></a> [keda\_namespace](#input\_keda\_namespace) | Namespace to install KEDA into | `string` | `"keda"` | no |
| <a name="input_keda_version"></a> [keda\_version](#input\_keda\_version) | The version of the KEDA Helm chart to be deployed, used for Kubernetes-based Event-Driven Autoscaling. | `string` | `"2.16.1"` | no |
| <a name="input_keda_yml_file"></a> [keda\_yml\_file](#input\_keda\_yml\_file) | Optional custom values YAML file for KEDA | `string` | `null` | no |
| <a name="input_kubecost_enabled"></a> [kubecost\_enabled](#input\_kubecost\_enabled) | A boolean to enable or disable the deployment of Kubecost, a tool for monitoring and managing Kubernetes cost and resource usage. | `bool` | `false` | no |
| <a name="input_kubecost_version"></a> [kubecost\_version](#input\_kubecost\_version) | The version of the Kubecost Helm chart to be deployed, used for Kubernetes cost management and optimization. | `string` | `"2.5.3"` | no |
| <a name="input_loki_chart_version"></a> [loki\_chart\_version](#input\_loki\_chart\_version) | n/a | `string` | `"5.43.3"` | no |
| <a name="input_loki_values_file"></a> [loki\_values\_file](#input\_loki\_values\_file) | n/a | `any` | `null` | no |
| <a name="input_loki_version"></a> [loki\_version](#input\_loki\_version) | The version of the Loki Helm chart to be deployed, used for log aggregation and analysis. | `string` | `"6.25.0"` | no |
| <a name="input_nginx_max_replicas"></a> [nginx\_max\_replicas](#input\_nginx\_max\_replicas) | Maximum number of Nginx Replicas | `number` | `11` | no |
| <a name="input_nginx_min_replicas"></a> [nginx\_min\_replicas](#input\_nginx\_min\_replicas) | Minimum number of Nginx Replicas | `number` | `2` | no |
| <a name="input_nginx_name"></a> [nginx\_name](#input\_nginx\_name) | Release name for the installed helm chart | `string` | `"nginx"` | no |
| <a name="input_nginx_yml_file"></a> [nginx\_yml\_file](#input\_nginx\_yml\_file) | n/a | `any` | `null` | no |
| <a name="input_opentelemetry_collector_version"></a> [opentelemetry\_collector\_version](#input\_opentelemetry\_collector\_version) | The version of the OpenTelemetry Collector Helm chart to be deployed, used for collecting telemetry data (logs, metrics, and traces) from various sources. | `string` | `"0.115.0"` | no |
| <a name="input_otel_yml_file"></a> [otel\_yml\_file](#input\_otel\_yml\_file) | n/a | `any` | `null` | no |
| <a name="input_prometheus_additional_scrape_configs"></a> [prometheus\_additional\_scrape\_configs](#input\_prometheus\_additional\_scrape\_configs) | Add additional scrape for configuration for prometheus if needed | <pre>list(object({<br>    job_name        = string<br>    targets         = list(string)<br>    scrape_interval = string<br>    metrics_path    = string<br>  }))</pre> | `[]` | no |
| <a name="input_prometheus_enabled"></a> [prometheus\_enabled](#input\_prometheus\_enabled) | Enable prometheus | `bool` | `false` | no |
| <a name="input_prometheus_persistence_storage"></a> [prometheus\_persistence\_storage](#input\_prometheus\_persistence\_storage) | Enable persistence storage for Prometheus | `bool` | `false` | no |
| <a name="input_prometheus_version"></a> [prometheus\_version](#input\_prometheus\_version) | The version of the Prometheus Helm chart to be deployed, used for monitoring and alerting in Kubernetes. | `string` | `"27.1.0"` | no |
| <a name="input_promtail_version"></a> [promtail\_version](#input\_promtail\_version) | The version of the Promtail Helm chart to be deployed, used as a log collector to send logs to Loki. | `string` | `"6.16.6"` | no |
| <a name="input_pushgateway_ingress_host"></a> [pushgateway\_ingress\_host](#input\_pushgateway\_ingress\_host) | List of hosts for prometheus push gateway ingress | `list` | `[]` | no |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | Storage Class to use for Persistence | `string` | `"managed-csi"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->