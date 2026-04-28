<p align="center">
  <img src="https://github.com/cypik.png" alt="Cypik Logo" width="120"/>
</p>

<h1 align="center">Terraform Helm Charts — by Cypik</h1>

<p align="center">
  <strong>Modular, Scalable, Production-Ready Kubernetes Deployments</strong><br/>
  Grafana · Loki · Prometheus · NGINX · Cert-Manager · KEDA · Karpenter · ALB Controller · Metrics Server · Calico · CSI Secrets Store · MySQL Exporter · CloudWatch Exporter
</p>

---

## Module Overview

This module is maintained by the **DevOps team at [Cypik](https://github.com/cypik)** to simplify and standardize the deployment of observability, ingress, and autoscaling components using Helm and Terraform on Kubernetes.

Each component is independently toggle-able. Components that are cloud-specific (CloudWatch, ALB Controller, Karpenter, IRSA roles) are gated behind their own flags and are safe to disable on Azure or GCP.

| Component | Flag | Cloud |
|---|---|---|
| Grafana | `grafana_enabled` | Any |
| Loki + Promtail | `grafana_loki_enabled` | Any |
| Prometheus | `prometheus_enabled` | Any |
| NGINX Ingress | `nginx_ingress_enabled` | Any |
| Cert-Manager | `cert_manager_enabled` | Any |
| Metrics Server | `metrics_server_enabled` | Any |
| KEDA | `keda_enabled` | Any |
| MySQL Exporter | `mysql_exporter_enabled` | Any |
| Calico | `calico_enabled` | Any |
| CSI Secrets Store | `csi_secrets_store_enabled` | AWS |
| ALB Ingress Controller | `alb_ingress_enabled` | AWS |
| Karpenter | `karpenter_enabled` | AWS |
| CloudWatch Integration | `rds_cloudwatch_datasource_enabled` | AWS |

---

## Usage Example

```hcl
module "helm-charts" {
  source     = "cypik/terraform-helm-charts/aws"
  version    = "1.0.0"

  # Cluster
  cluster_name        = "my-eks-cluster"
  vpc_id              = "vpc-xxxxxxxxxxxxxxxxx"
  eks_oidc_issuer_url = "https://oidc.eks.us-east-1.amazonaws.com/id/XXXXXXXXXX"
  region              = "us-east-1"

  # NGINX Ingress
  nginx_ingress_enabled = true

  # Cert-Manager
  cert_manager_enabled = true
  cert_manager_email   = "admin@example.com"

  # Grafana
  grafana_enabled       = true
  grafana_ingress_hosts = ["grafana.example.com"]
  grafana_loki_enabled  = true

  # Prometheus
  prometheus_enabled = true

  # MySQL Exporter — works on any cloud (AWS RDS, Azure, GCP Cloud SQL)
  mysql_exporter_enabled = true
  db_endpoint            = "my-db.us-east-1.rds.amazonaws.com:3306"
  db_username            = "exporter"
  db_exporter_password   = "securepassword"

  # Node Exporter Dashboard in Grafana
  node_exporter_dashboard_enabled = true

  # CloudWatch Integration — AWS only, disable on Azure/GCP
  rds_cloudwatch_datasource_enabled = false

  # ALB Ingress Controller — AWS only
  alb_ingress_enabled = false

  # Karpenter — AWS only
  karpenter_enabled = false

  # KEDA
  keda_enabled = false

  # Calico
  calico_enabled = false

  # CSI Secrets Store — AWS only
  csi_secrets_store_enabled = false
  csi_enabled_namespaces    = ["default"]

  # Metrics Server
  metrics_server_enabled = false
}
```

---

## Dashboard Behaviour

| Flag | Grafana Folder | Dashboard | Datasource |
|---|---|---|---|
| `mysql_exporter_enabled = true` | DB | MySQL Overview (7362) | Prometheus |
| `rds_cloudwatch_datasource_enabled = true` | AWS RDS | AWS RDS (707) | CloudWatch |
| `node_exporter_dashboard_enabled = true` | Nodes | Node Exporter Full (1860) | Prometheus |

Both `mysql_exporter_enabled` and `rds_cloudwatch_datasource_enabled` can be enabled at the same time on AWS — you will get both the **DB** and **AWS RDS** folders in Grafana.

---

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.karpenter_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.alb_ingress_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cloudwatch_exporter_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.grafana_cloudwatch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.secrets_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.alb_ingress_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cloudwatch_exporter_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.grafana_cloudwatch_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.karpenter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.karpenter_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.secrets_manager_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.karpenter_controller_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.alb_ingress_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.grafana_cloudwatch_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.karpenter_node_managed_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.secrets_manager_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sqs_queue.karpenter_interruption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [helm_release.aws_load_balancer_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.calico](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cert-manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cloudwatch_exporter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.csi_secrets_store](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.db_mysql_exporter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.grafana](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.karpenter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.keda](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.loki](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.nginx](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.prometheus](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.promtail](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_service_account.aws_lb_controller_sa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [null_resource.cert-manager-cluster-issuer](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.csi_secrets_store_aws_provider](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.grafana_admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_openid_connect_provider.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_openid_connect_provider.oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_openid_connect_provider.oidc-alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_openid_connect_provider.oidc-csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_policy_document.trust_relationship](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [http_http.csi_secrets_store_aws_provider](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_ingress_enabled"></a> [alb\_ingress\_enabled](#input\_alb\_ingress\_enabled) | Enable or disable the AWS Load Balancer Controller deployment. | `bool` | `false` | no |
| <a name="input_alb_ingress_version"></a> [alb\_ingress\_version](#input\_alb\_ingress\_version) | Version of the aws-load-balancer-controller Helm chart to deploy. | `string` | `"3.0.0"` | no |
| <a name="input_alertmanager_persistence_enabled"></a> [alertmanager\_persistence\_enabled](#input\_alertmanager\_persistence\_enabled) | Enable persistent storage for Alertmanager. | `bool` | `false` | no |
| <a name="input_calico_enabled"></a> [calico\_enabled](#input\_calico\_enabled) | Enable or disable the Calico network policy engine deployment. | `bool` | `false` | no |
| <a name="input_calico_version"></a> [calico\_version](#input\_calico\_version) | Version of the Calico (tigera-operator) Helm chart to deploy. | `string` | `"v3.27.0"` | no |
| <a name="input_cert_manager_email"></a> [cert\_manager\_email](#input\_cert\_manager\_email) | Email address used by cert-manager for Let's Encrypt ACME registration and expiry notifications. | `string` | `null` | no |
| <a name="input_cert_manager_enabled"></a> [cert\_manager\_enabled](#input\_cert\_manager\_enabled) | Enable or disable cert-manager deployment for automated TLS certificate management. | `bool` | `false` | no |
| <a name="input_cert_manager_leader_election_namespace"></a> [cert\_manager\_leader\_election\_namespace](#input\_cert\_manager\_leader\_election\_namespace) | Namespace used for cert-manager leader election lease. Set to cert-manager for GKE Autopilot. | `string` | `"cert-manager"` | no |
| <a name="input_cert_manager_resources"></a> [cert\_manager\_resources](#input\_cert\_manager\_resources) | CPU and memory resource limits/requests for cert-manager pods. Keys are resource types (e.g. limits, requests). | <pre>map(object({<br>    cpu    = string<br>    memory = string<br>  }))</pre> | `null` | no |
| <a name="input_cert_manager_version"></a> [cert\_manager\_version](#input\_cert\_manager\_version) | Version of the cert-manager Helm chart to deploy. | `string` | `"1.19.3"` | no |
| <a name="input_cloudwatch_exporter_version"></a> [cloudwatch\_exporter\_version](#input\_cloudwatch\_exporter\_version) | Version of the prometheus-cloudwatch-exporter Helm chart to deploy. | `string` | `"0.28.1"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the existing EKS cluster. Used for IRSA trust policies and CloudWatch exporter configuration. | `string` | `""` | no |
| <a name="input_csi_enabled_namespaces"></a> [csi\_enabled\_namespaces](#input\_csi\_enabled\_namespaces) | List of namespaces in which to create a CSI secrets service account. | `list(string)` | `[]` | no |
| <a name="input_csi_secrets_store_enabled"></a> [csi\_secrets\_store\_enabled](#input\_csi\_secrets\_store\_enabled) | Enable or disable the Secrets Store CSI driver for mounting secrets from AWS Secrets Manager. | `bool` | `false` | no |
| <a name="input_csi_secrets_store_version"></a> [csi\_secrets\_store\_version](#input\_csi\_secrets\_store\_version) | Version of the secrets-store-csi-driver Helm chart to deploy. | `string` | `"1.4.6"` | no |
| <a name="input_db_endpoint"></a> [db\_endpoint](#input\_db\_endpoint) | MySQL-compatible database endpoint (host:port). Supports AWS RDS, Azure Database for MySQL, GCP Cloud SQL, etc. | `string` | `""` | no |
| <a name="input_db_exporter_password"></a> [db\_exporter\_password](#input\_db\_exporter\_password) | Password for the database exporter user. | `string` | `""` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Database username the MySQL exporter uses to connect and scrape metrics. | `string` | `"user"` | no |
| <a name="input_eks_oidc_issuer_url"></a> [eks\_oidc\_issuer\_url](#input\_eks\_oidc\_issuer\_url) | OIDC issuer URL of the EKS cluster (including https://). Used to create IRSA trust policies. | `string` | `""` | no |
| <a name="input_grafana_acm_certificate_arn"></a> [grafana\_acm\_certificate\_arn](#input\_grafana\_acm\_certificate\_arn) | ACM certificate ARN to use for HTTPS on the ALB ingress. Required when grafana\_ingress\_type is alb. | `string` | `""` | no |
| <a name="input_grafana_admin_password"></a> [grafana\_admin\_password](#input\_grafana\_admin\_password) | Admin password for the Grafana dashboard login. A random password is generated when left empty. | `string` | `"cypik@123"` | no |
| <a name="input_grafana_admin_user"></a> [grafana\_admin\_user](#input\_grafana\_admin\_user) | Admin username for the Grafana dashboard login. | `string` | `"cypik"` | no |
| <a name="input_grafana_cloudwatch_region"></a> [grafana\_cloudwatch\_region](#input\_grafana\_cloudwatch\_region) | AWS region for the Grafana CloudWatch datasource. Falls back to the region variable when empty. | `string` | `""` | no |
| <a name="input_grafana_datasources"></a> [grafana\_datasources](#input\_grafana\_datasources) | Additional datasources to provision in Grafana alongside the built-in Prometheus and Loki datasources. | <pre>list(object({<br>    name      = string<br>    type      = string<br>    url       = string<br>    access    = string<br>    isDefault = bool<br>  }))</pre> | `[]` | no |
| <a name="input_grafana_efs_storage_class_name"></a> [grafana\_efs\_storage\_class\_name](#input\_grafana\_efs\_storage\_class\_name) | StorageClass name to use when EFS is required. Ensure the EFS CSI driver is deployed before enabling. | `string` | `"gp3"` | no |
| <a name="input_grafana_enabled"></a> [grafana\_enabled](#input\_grafana\_enabled) | Enable or disable the Grafana deployment. | `bool` | `false` | no |
| <a name="input_grafana_extra_yml"></a> [grafana\_extra\_yml](#input\_grafana\_extra\_yml) | Optional extra Helm values YAML to override or extend grafana.yml (e.g. grafana\_extra\_yml = file("grafana-override.yml")). | `string` | `null` | no |
| <a name="input_grafana_google_auth_client_id"></a> [grafana\_google\_auth\_client\_id](#input\_grafana\_google\_auth\_client\_id) | Google OAuth2 client ID for Grafana SSO login. | `string` | `""` | no |
| <a name="input_grafana_google_auth_client_secret"></a> [grafana\_google\_auth\_client\_secret](#input\_grafana\_google\_auth\_client\_secret) | Google OAuth2 client secret for Grafana SSO login. | `string` | `""` | no |
| <a name="input_grafana_ingress_enabled"></a> [grafana\_ingress\_enabled](#input\_grafana\_ingress\_enabled) | Enable or disable ingress for Grafana. | `bool` | `true` | no |
| <a name="input_grafana_ingress_hosts"></a> [grafana\_ingress\_hosts](#input\_grafana\_ingress\_hosts) | List of hostnames to configure for the Grafana ingress. | `list(string)` | `[]` | no |
| <a name="input_grafana_ingress_type"></a> [grafana\_ingress\_type](#input\_grafana\_ingress\_type) | Ingress controller type for Grafana. Accepted values: alb \| nginx \| none. | `string` | `"nginx"` | no |
| <a name="input_grafana_loki_enabled"></a> [grafana\_loki\_enabled](#input\_grafana\_loki\_enabled) | Enable or disable Loki and Promtail deployment and add Loki as a Grafana datasource. | `bool` | `false` | no |
| <a name="input_grafana_persistence_access_modes"></a> [grafana\_persistence\_access\_modes](#input\_grafana\_persistence\_access\_modes) | Access modes for the Grafana persistent volume claim. | `list(string)` | <pre>[<br>  "ReadWriteOnce"<br>]</pre> | no |
| <a name="input_grafana_persistence_enabled"></a> [grafana\_persistence\_enabled](#input\_grafana\_persistence\_enabled) | Enable persistent storage for Grafana to retain dashboards and settings across restarts. | `bool` | `true` | no |
| <a name="input_grafana_persistence_size"></a> [grafana\_persistence\_size](#input\_grafana\_persistence\_size) | Size of the persistent volume claim for Grafana. | `string` | `"5Gi"` | no |
| <a name="input_grafana_persistence_storage_class"></a> [grafana\_persistence\_storage\_class](#input\_grafana\_persistence\_storage\_class) | StorageClass used for the Grafana persistent volume claim. | `string` | `"gp3"` | no |
| <a name="input_grafana_version"></a> [grafana\_version](#input\_grafana\_version) | Version of the Grafana Helm chart to deploy. | `string` | `"11.1.0"` | no |
| <a name="input_ingress_nginx_version"></a> [ingress\_nginx\_version](#input\_ingress\_nginx\_version) | Version of the ingress-nginx Helm chart to deploy. | `string` | `"4.14.3"` | no |
| <a name="input_karpenter_enabled"></a> [karpenter\_enabled](#input\_karpenter\_enabled) | Enable or disable the Karpenter node autoprovisioner deployment. | `bool` | `false` | no |
| <a name="input_karpenter_version"></a> [karpenter\_version](#input\_karpenter\_version) | Version of the Karpenter Helm chart to deploy. | `string` | `"1.6.1"` | no |
| <a name="input_keda_chart_version"></a> [keda\_chart\_version](#input\_keda\_chart\_version) | Version of the KEDA Helm chart to deploy. | `string` | `"2.13.0"` | no |
| <a name="input_keda_enabled"></a> [keda\_enabled](#input\_keda\_enabled) | Enable or disable the KEDA (Kubernetes Event-Driven Autoscaling) deployment. | `bool` | `false` | no |
| <a name="input_keda_name"></a> [keda\_name](#input\_keda\_name) | Helm release name for KEDA. | `string` | `"keda"` | no |
| <a name="input_keda_namespace"></a> [keda\_namespace](#input\_keda\_namespace) | Kubernetes namespace to install KEDA into. | `string` | `"keda"` | no |
| <a name="input_loki_custom_values"></a> [loki\_custom\_values](#input\_loki\_custom\_values) | Custom YAML values for the Loki Helm chart. Overrides built-in defaults when provided. | `string` | `null` | no |
| <a name="input_loki_storage_size"></a> [loki\_storage\_size](#input\_loki\_storage\_size) | Persistent volume size for Loki log storage. | `string` | `"10Gi"` | no |
| <a name="input_loki_version"></a> [loki\_version](#input\_loki\_version) | Version of the Loki Helm chart to deploy. | `string` | `"6.52.0"` | no |
| <a name="input_metrics_server_enabled"></a> [metrics\_server\_enabled](#input\_metrics\_server\_enabled) | Enable or disable the metrics-server deployment for Kubernetes resource metrics. | `bool` | `false` | no |
| <a name="input_metrics_server_version"></a> [metrics\_server\_version](#input\_metrics\_server\_version) | Version of the metrics-server Helm chart to deploy. | `string` | `"3.13.0"` | no |
| <a name="input_mysql_exporter_enabled"></a> [mysql\_exporter\_enabled](#input\_mysql\_exporter\_enabled) | Enable or disable the MySQL exporter deployment. Works on any cloud (AWS RDS, Azure Database for MySQL, GCP Cloud SQL). | `bool` | `false` | no |
| <a name="input_mysql_exporter_version"></a> [mysql\_exporter\_version](#input\_mysql\_exporter\_version) | Version of the prometheus-mysql-exporter Helm chart to deploy. | `string` | `"2.12.0"` | no |
| <a name="input_nginx_ingress_enabled"></a> [nginx\_ingress\_enabled](#input\_nginx\_ingress\_enabled) | Enable or disable the NGINX ingress controller deployment. | `bool` | `false` | no |
| <a name="input_nginx_yml_file"></a> [nginx\_yml\_file](#input\_nginx\_yml\_file) | Path to a custom YAML values file for the NGINX ingress Helm chart. Uses the built-in nginx.yml when null. | `string` | `null` | no |
| <a name="input_node_exporter_dashboard_enabled"></a> [node\_exporter\_dashboard\_enabled](#input\_node\_exporter\_dashboard\_enabled) | Enable Grafana dashboard 1860 (Node Exporter Full) for Kubernetes node-level metrics. Requires Prometheus and node-exporter running in the cluster. | `bool` | `false` | no |
| <a name="input_prometheus_custom_values"></a> [prometheus\_custom\_values](#input\_prometheus\_custom\_values) | Custom YAML values for the Prometheus Helm chart. Overrides built-in defaults when provided. | `string` | `null` | no |
| <a name="input_prometheus_enabled"></a> [prometheus\_enabled](#input\_prometheus\_enabled) | Enable or disable the Prometheus deployment. | `bool` | `false` | no |
| <a name="input_prometheus_persistence_storage"></a> [prometheus\_persistence\_storage](#input\_prometheus\_persistence\_storage) | Enable persistent storage for the Prometheus server. | `bool` | `true` | no |
| <a name="input_prometheus_persistent_volume_existing_claim"></a> [prometheus\_persistent\_volume\_existing\_claim](#input\_prometheus\_persistent\_volume\_existing\_claim) | Name of an existing PersistentVolumeClaim to use for Prometheus instead of creating a new one. | `string` | `""` | no |
| <a name="input_prometheus_persistent_volume_size"></a> [prometheus\_persistent\_volume\_size](#input\_prometheus\_persistent\_volume\_size) | Size of the persistent volume for the Prometheus server. | `string` | `"8Gi"` | no |
| <a name="input_prometheus_pod_security_policy_enabled"></a> [prometheus\_pod\_security\_policy\_enabled](#input\_prometheus\_pod\_security\_policy\_enabled) | Enable PodSecurityPolicy for the Prometheus deployment. | `bool` | `true` | no |
| <a name="input_prometheus_server_retention"></a> [prometheus\_server\_retention](#input\_prometheus\_server\_retention) | Data retention period for the Prometheus server (e.g. 1d, 7d, 30d). | `string` | `"1d"` | no |
| <a name="input_prometheus_storage_class"></a> [prometheus\_storage\_class](#input\_prometheus\_storage\_class) | StorageClass used for the Prometheus persistent volume. | `string` | `"gp3"` | no |
| <a name="input_prometheus_version"></a> [prometheus\_version](#input\_prometheus\_version) | Version of the Prometheus Helm chart to deploy. | `string` | `"28.6.0"` | no |
| <a name="input_promtail_version"></a> [promtail\_version](#input\_promtail\_version) | Version of the Promtail Helm chart to deploy. | `string` | `"6.17.1"` | no |
| <a name="input_pushgateway_ingress_host"></a> [pushgateway\_ingress\_host](#input\_pushgateway\_ingress\_host) | List of hostnames to configure for the Prometheus Pushgateway ingress. | `list(string)` | `[]` | no |
| <a name="input_rds_cloudwatch_datasource_enabled"></a> [rds\_cloudwatch\_datasource\_enabled](#input\_rds\_cloudwatch\_datasource\_enabled) | Enable all AWS CloudWatch integration: CloudWatch exporter for Prometheus, CloudWatch datasource in Grafana, and required IRSA roles. AWS-only — set false on Azure/GCP. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region for CloudWatch exporter and Grafana CloudWatch datasource. | `string` | `"us-east-1"` | no |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | Default storage class used for persistent volumes across all deployed components. | `string` | `"gp3"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID of the cluster. Required when alb\_ingress\_enabled is true. | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
