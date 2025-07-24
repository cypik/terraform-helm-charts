variable "storage_class" {
  default     = "managed-csi"
  description = "Storage Class to use for Persistence"
}

variable "nginx_name" {
  default     = "nginx"
  description = "Release name for the installed helm chart"
}

variable "nginx_yml_file" {
  default = null
}

variable "enable_nginx" {
  type        = bool
  default     = true
  description = "Whether to enable nginx ingress"
}

variable "nginx_min_replicas" {
  default     = 2
  description = "Minimum number of Nginx Replicas"
}

variable "nginx_max_replicas" {
  default     = 11
  description = "Maximum number of Nginx Replicas"
}

variable "cert_manager_email" {
  default     = null
  description = "Your email address to use for cert manager"
}


variable "grafana_enabled" {
  default     = false
  description = "Enable grafana"
}

variable "grafana_admin_user" {
  default     = "Cypik"
  description = "The User name of Grafana for login Dashboard"
}

variable "grafana_admin_password" {
  default     = "Cypik"
  description = "The Password of Grafana for login Dashboard"
}

variable "grafana_ingress_enabled" {
  default     = false
  description = "Enable grafana ingress"
}

variable "grafana_ingress_hosts" {
  default     = []
  description = "Add grafana ingress hosts"
}

variable "grafana_google_auth_client_id" {
  default     = ""
  description = "Add Google Auth client id"
}

variable "grafana_google_auth_client_secret" {
  default     = ""
  description = "Add Google Auth client secret"
}

variable "grafana_persistence_storage" {
  default     = true
  description = "Enable persistence storage for Grafana"
}

variable "grafana_extra_yml" {
  default     = null
  description = "Grafana Datasources as Yaml"
}

variable "grafana_efs_enable" {
  default     = false
  description = "Enable EFS storage for Grafana"
}
variable "grafana_efs_storage_class_name" {
  default     = "gp2"
  description = "If EFS is needed pass EFS storage class, but make sure efs and efs driver deployed"
}

variable "grafana_datasources" {
  type = list(object({
    name      = string
    type      = string
    url       = string
    access    = string
    isDefault = bool
  }))
  default = [
    #     {
    #       name      = "Postgres"
    #       type      = "postgres"
    #       url       = "postgresql://user:password@postgres-server.database.svc.cluster.local:5432/dbname"
    #       access    = "proxy"
    #       isDefault = false
    #     },
    #     {
    #       name      = "Loki"
    #       type      = "loki"
    #       url       = "http://loki-server.loki.svc.cluster.local"
    #       access    = "proxy"
    #       isDefault = false # This should be false
    #     }
  ]
}

#loki
variable "grafana_loki_enabled" {
  default     = true
  description = "Enable grafana loki"
}

variable "grafana_loki_yml_file" {
  default = null
}
variable "otel_yml_file" {
  default = null
}


variable "grafana_loki_bucket_name" {
  type        = string
  default     = ""
  description = "Name for the S3 bucket"
}

variable "prometheus_persistence_storage" {
  default     = false
  description = "Enable persistence storage for Prometheus"
}

variable "prometheus_additional_scrape_configs" {
  type = list(object({
    job_name        = string
    targets         = list(string)
    scrape_interval = string
    metrics_path    = string
  }))
  default     = []
  description = "Add additional scrape for configuration for prometheus if needed"
}

variable "pushgateway_ingress_host" {
  default     = []
  description = "List of hosts for prometheus push gateway ingress"
}

variable "prometheus_enabled" {
  default     = false
  description = "Enable prometheus"
}

variable "cert_manager_leader_election_namespace" {
  default     = "cert-manager"
  description = "The namespace used for the leader election lease. Change to cert-manager for GKE Autopilot"
}

variable "cert_manager_resources" {
  type = map(object({
    cpu    = string
    memory = string
  }))
  default = null # You can set a default value if needed
}

variable "cert_manager_version" {
  description = "The version of the Cert-Manager Helm chart to be deployed, used for automating the issuance and renewal of TLS certificates."
  default     = "1.16.3"
}

variable "kubecost_enabled" {
  description = "A boolean to enable or disable the deployment of Kubecost, a tool for monitoring and managing Kubernetes cost and resource usage."
  default     = false
}

variable "datadog_version" {
  description = "The version of the Datadog Helm chart to be deployed, used for monitoring, security, and observability in Kubernetes environments."
  default     = "3.88.3"
}

variable "grafana_version" {
  description = "The version of the Grafana Helm chart to be deployed, used for data visualization and monitoring dashboards."
  default     = "8.8.5"
}

variable "keda_version" {
  description = "The version of the KEDA Helm chart to be deployed, used for Kubernetes-based Event-Driven Autoscaling."
  default     = "2.16.1"
}

variable "kubecost_version" {
  description = "The version of the Kubecost Helm chart to be deployed, used for Kubernetes cost management and optimization."
  default     = "2.5.3"
}

variable "loki_version" {
  description = "The version of the Loki Helm chart to be deployed, used for log aggregation and analysis."
  default     = "6.25.0"
}

variable "promtail_version" {
  description = "The version of the Promtail Helm chart to be deployed, used as a log collector to send logs to Loki."
  default     = "6.16.6"
}

variable "ingress_nginx_version" {
  description = "The version of the Ingress-NGINX Helm chart to be deployed, used for managing ingress traffic in Kubernetes."
  default     = "4.12.1"
}

variable "opentelemetry_collector_version" {
  description = "The version of the OpenTelemetry Collector Helm chart to be deployed, used for collecting telemetry data (logs, metrics, and traces) from various sources."
  default     = "0.115.0"
}

variable "prometheus_version" {
  description = "The version of the Prometheus Helm chart to be deployed, used for monitoring and alerting in Kubernetes."
  default     = "27.1.0"
}


## keda

variable "enable_keda" {
  description = "Whether to deploy KEDA"
  type        = bool
  default     = false
}

variable "keda_name" {
  description = "Name of the Helm release for KEDA"
  type        = string
  default     = "keda"
}

variable "keda_namespace" {
  description = "Namespace to install KEDA into"
  type        = string
  default     = "keda"
}

variable "keda_chart_version" {
  description = "Version of the KEDA chart"
  type        = string
  default     = "2.13.0"
}

variable "keda_yml_file" {
  description = "Optional custom values YAML file for KEDA"
  type        = string
  default     = null
}

variable "enable_grafana" {
  description = "Enable Grafana deployment"
  type        = bool
  default     = true
}

variable "grafana_name" {
  description = "Name of the Grafana release"
  type        = string
  default     = "grafana"
}

variable "grafana_chart_version" {
  description = "Grafana Helm chart version"
  type        = string
  default     = "7.3.0"
}


variable "grafana_values_file" {
  description = "Optional values YAML file for Grafana"
  type        = string
  default     = null
}


########### loki testing only not deploy

variable "cloud_provider" {
  description = "Choose between aws or azure"
  type        = string
  default     = "azure"
}



variable "loki_chart_version" {
  default = "5.43.3" # Or latest
}



variable "loki_values_file" {
  default = null
}


variable "grafana_loki_storage_name" {
  type    = string
  default = "jdhdjhd8384839hf"
}

variable "grafana_loki_container_name" {
  type    = string
  default = "jknqwjkdqwkd"
}

variable "cert_manager_enabled" {
  description = "Enable cert-manager deployment"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "The name of the existing EKS cluster"
  type        = string
}

variable "enabled_karpenter" {
  description = "Enable or disable the Karpenter provisioning"
  type        = bool
  default     = false
}

variable "grafana_ingress_class_name" {
  default     = "nginx"
  description = "Ingress class name for Grafana"
}
