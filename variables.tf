variable "storage_class" {
  type        = string
  default     = "gp3"
  description = "Default storage class used for persistent volumes across all deployed components."
}

variable "nginx_yml_file" {
  type        = string
  default     = null
  description = "Path to a custom YAML values file for the NGINX ingress Helm chart. Uses the built-in nginx.yml when null."
}

variable "nginx_ingress_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the NGINX ingress controller deployment."
}

variable "cert_manager_email" {
  type        = string
  default     = null
  description = "Email address used by cert-manager for Let's Encrypt ACME registration and expiry notifications."
}

variable "cert_manager_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable cert-manager deployment for automated TLS certificate management."
}

variable "cert_manager_version" {
  type        = string
  default     = "1.19.3"
  description = "Version of the cert-manager Helm chart to deploy."
}

variable "cert_manager_leader_election_namespace" {
  type        = string
  default     = "cert-manager"
  description = "Namespace used for cert-manager leader election lease. Set to cert-manager for GKE Autopilot."
}

variable "cert_manager_resources" {
  type = map(object({
    cpu    = string
    memory = string
  }))
  default     = null
  description = "CPU and memory resource limits/requests for cert-manager pods. Keys are resource types (e.g. limits, requests)."
}

variable "grafana_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the Grafana deployment."
}

variable "grafana_version" {
  type        = string
  default     = "11.1.0"
  description = "Version of the Grafana Helm chart to deploy."
}

variable "grafana_admin_user" {
  type        = string
  default     = "cypik"
  description = "Admin username for the Grafana dashboard login."
}

variable "grafana_admin_password" {
  type        = string
  default     = "cypik@123"
  description = "Admin password for the Grafana dashboard login. A random password is generated when left empty."
}

variable "grafana_ingress_enabled" {
  type        = bool
  default     = true
  description = "Enable or disable ingress for Grafana."
}

variable "grafana_ingress_type" {
  type        = string
  default     = "nginx"
  description = "Ingress controller type for Grafana. Accepted values: alb | nginx | none."
}

variable "grafana_ingress_hosts" {
  type        = list(string)
  default     = []
  description = "List of hostnames to configure for the Grafana ingress."
}

variable "grafana_acm_certificate_arn" {
  type        = string
  default     = ""
  description = "ACM certificate ARN to use for HTTPS on the ALB ingress. Required when grafana_ingress_type is alb."
}

variable "grafana_google_auth_client_id" {
  type        = string
  default     = ""
  description = "Google OAuth2 client ID for Grafana SSO login."
}

variable "grafana_google_auth_client_secret" {
  type        = string
  default     = ""
  description = "Google OAuth2 client secret for Grafana SSO login."
}

variable "grafana_persistence_enabled" {
  type        = bool
  default     = true
  description = "Enable persistent storage for Grafana to retain dashboards and settings across restarts."
}

variable "grafana_persistence_storage_class" {
  type        = string
  default     = "gp3"
  description = "StorageClass used for the Grafana persistent volume claim."
}

variable "grafana_persistence_size" {
  type        = string
  default     = "5Gi"
  description = "Size of the persistent volume claim for Grafana."
}

variable "grafana_persistence_access_modes" {
  type        = list(string)
  default     = ["ReadWriteOnce"]
  description = "Access modes for the Grafana persistent volume claim."
}

variable "grafana_efs_storage_class_name" {
  type        = string
  default     = "gp3"
  description = "StorageClass name to use when EFS is required. Ensure the EFS CSI driver is deployed before enabling."
}

variable "grafana_extra_yml" {
  type        = string
  default     = null
  description = "Optional extra Helm values YAML to override or extend grafana.yml (e.g. grafana_extra_yml = file(\"grafana-override.yml\"))."
}

variable "grafana_datasources" {
  type = list(object({
    name      = string
    type      = string
    url       = string
    access    = string
    isDefault = bool
  }))
  default     = []
  description = "Additional datasources to provision in Grafana alongside the built-in Prometheus and Loki datasources."
}

variable "grafana_loki_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable Loki and Promtail deployment and add Loki as a Grafana datasource."
}

variable "grafana_cloudwatch_region" {
  type        = string
  default     = ""
  description = "AWS region for the Grafana CloudWatch datasource. Falls back to the region variable when empty."
}

variable "rds_cloudwatch_datasource_enabled" {
  type        = bool
  default     = false
  description = "Enable all AWS CloudWatch integration: CloudWatch exporter for Prometheus, CloudWatch datasource in Grafana, and required IRSA roles. AWS-only — set false on Azure/GCP."
}

variable "loki_version" {
  type        = string
  default     = "6.52.0"
  description = "Version of the Loki Helm chart to deploy."
}

variable "loki_storage_size" {
  type        = string
  default     = "10Gi"
  description = "Persistent volume size for Loki log storage."
}

variable "loki_custom_values" {
  type        = string
  default     = null
  description = "Custom YAML values for the Loki Helm chart. Overrides built-in defaults when provided."
}

variable "promtail_version" {
  type        = string
  default     = "6.17.1"
  description = "Version of the Promtail Helm chart to deploy."
}

variable "prometheus_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the Prometheus deployment."
}

variable "prometheus_version" {
  type        = string
  default     = "28.6.0"
  description = "Version of the Prometheus Helm chart to deploy."
}

variable "prometheus_custom_values" {
  type        = string
  default     = null
  description = "Custom YAML values for the Prometheus Helm chart. Overrides built-in defaults when provided."
}

variable "prometheus_persistence_storage" {
  type        = bool
  default     = true
  description = "Enable persistent storage for the Prometheus server."
}

variable "prometheus_pod_security_policy_enabled" {
  type        = bool
  default     = true
  description = "Enable PodSecurityPolicy for the Prometheus deployment."
}

variable "prometheus_server_retention" {
  type        = string
  default     = "1d"
  description = "Data retention period for the Prometheus server (e.g. 1d, 7d, 30d)."
}

variable "prometheus_storage_class" {
  type        = string
  default     = "gp3"
  description = "StorageClass used for the Prometheus persistent volume."
}

variable "prometheus_persistent_volume_existing_claim" {
  type        = string
  default     = ""
  description = "Name of an existing PersistentVolumeClaim to use for Prometheus instead of creating a new one."
}

variable "prometheus_persistent_volume_size" {
  type        = string
  default     = "8Gi"
  description = "Size of the persistent volume for the Prometheus server."
}

variable "alertmanager_persistence_enabled" {
  type        = bool
  default     = false
  description = "Enable persistent storage for Alertmanager."
}

variable "pushgateway_ingress_host" {
  type        = list(string)
  default     = []
  description = "List of hostnames to configure for the Prometheus Pushgateway ingress."
}

variable "ingress_nginx_version" {
  type        = string
  default     = "4.14.3"
  description = "Version of the ingress-nginx Helm chart to deploy."
}

variable "alb_ingress_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the AWS Load Balancer Controller deployment."
}

variable "alb_ingress_version" {
  type        = string
  default     = "3.0.0"
  description = "Version of the aws-load-balancer-controller Helm chart to deploy."
}

variable "metrics_server_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the metrics-server deployment for Kubernetes resource metrics."
}

variable "metrics_server_version" {
  type        = string
  default     = "3.13.0"
  description = "Version of the metrics-server Helm chart to deploy."
}

variable "keda_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the KEDA (Kubernetes Event-Driven Autoscaling) deployment."
}

variable "keda_name" {
  type        = string
  default     = "keda"
  description = "Helm release name for KEDA."
}

variable "keda_namespace" {
  type        = string
  default     = "keda"
  description = "Kubernetes namespace to install KEDA into."
}

variable "keda_chart_version" {
  type        = string
  default     = "2.13.0"
  description = "Version of the KEDA Helm chart to deploy."
}

variable "karpenter_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the Karpenter node autoprovisioner deployment."
}

variable "karpenter_version" {
  type        = string
  default     = "1.6.1"
  description = "Version of the Karpenter Helm chart to deploy."
}

variable "calico_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the Calico network policy engine deployment."
}

variable "calico_version" {
  type        = string
  default     = "v3.27.0"
  description = "Version of the Calico (tigera-operator) Helm chart to deploy."
}

variable "csi_secrets_store_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the Secrets Store CSI driver for mounting secrets from AWS Secrets Manager."
}

variable "csi_secrets_store_version" {
  type        = string
  default     = "1.4.6"
  description = "Version of the secrets-store-csi-driver Helm chart to deploy."
}

variable "csi_enabled_namespaces" {
  type        = list(string)
  default     = []
  description = "List of namespaces in which to create a CSI secrets service account."
}

variable "cluster_name" {
  type        = string
  default     = ""
  description = "Name of the existing EKS cluster. Used for IRSA trust policies and CloudWatch exporter configuration."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID of the cluster. Required when alb_ingress_enabled is true."
}

variable "eks_oidc_issuer_url" {
  type        = string
  default     = ""
  description = "OIDC issuer URL of the EKS cluster (including https://). Used to create IRSA trust policies."
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for CloudWatch exporter and Grafana CloudWatch datasource."
}

variable "mysql_exporter_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the MySQL exporter deployment. Works on any cloud (AWS RDS, Azure Database for MySQL, GCP Cloud SQL)."
}

variable "mysql_exporter_version" {
  type        = string
  default     = "2.12.0"
  description = "Version of the prometheus-mysql-exporter Helm chart to deploy."
}

variable "db_endpoint" {
  type        = string
  default     = ""
  description = "MySQL-compatible database endpoint (host:port). Supports AWS RDS, Azure Database for MySQL, GCP Cloud SQL, etc."
}

variable "db_username" {
  type        = string
  default     = "user"
  description = "Database username the MySQL exporter uses to connect and scrape metrics."
}

variable "db_exporter_password" {
  type        = string
  default     = ""
  description = "Password for the database exporter user."
  sensitive   = true
}

variable "cloudwatch_exporter_version" {
  type        = string
  default     = "0.28.1"
  description = "Version of the prometheus-cloudwatch-exporter Helm chart to deploy."
}

variable "node_exporter_dashboard_enabled" {
  type        = bool
  default     = false
  description = "Enable Grafana dashboard 1860 (Node Exporter Full) for Kubernetes node-level metrics. Requires Prometheus and node-exporter running in the cluster."
}
