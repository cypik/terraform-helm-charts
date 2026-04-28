resource "random_password" "grafana_admin_password" {
  count   = var.grafana_enabled && var.grafana_admin_password == "" ? 1 : 0
  length  = 16
  special = true
}

resource "helm_release" "grafana" {
  count = var.grafana_enabled ? 1 : 0

  chart            = "grafana"
  name             = "grafana"
  namespace        = "grafana"
  create_namespace = true
  repository       = "https://grafana-community.github.io/helm-charts"
  version          = var.grafana_version

  values = [
    templatefile("${path.module}/grafana.yml", {
      GOOGLE_CLIENT_ID                  = var.grafana_google_auth_client_id
      GOOGLE_CLIENT_SECRET              = var.grafana_google_auth_client_secret,
      INGRESS_ENABLED                   = var.grafana_ingress_enabled,
      INGRESS_TYPE                      = var.grafana_ingress_type,
      INGRESS_HOSTS                     = var.grafana_ingress_hosts,
      datasources                       = var.grafana_datasources,
      grafana_loki_enabled              = var.grafana_loki_enabled,
      rds_cloudwatch_datasource_enabled = var.rds_cloudwatch_datasource_enabled,
      grafana_cloudwatch_region         = var.grafana_cloudwatch_region != "" ? var.grafana_cloudwatch_region : var.region,
      grafana_service_account_role_arn  = var.rds_cloudwatch_datasource_enabled && length(var.cluster_name) > 0 ? aws_iam_role.grafana_cloudwatch_role[0].arn : "",
      ACM_CERT_ARN                      = var.grafana_acm_certificate_arn,
      CERT_MANAGER_ENABLED              = var.cert_manager_enabled,
      #  persistence
      grafana_persistence_enabled       = var.grafana_persistence_enabled
      grafana_persistence_storage_class = var.grafana_persistence_storage_class
      grafana_persistence_size          = var.grafana_persistence_size
      grafana_persistence_access_modes  = var.grafana_persistence_access_modes
      mysql_exporter_enabled            = var.mysql_exporter_enabled
      node_exporter_dashboard_enabled   = var.node_exporter_dashboard_enabled
    }),
    var.grafana_extra_yml != null ? var.grafana_extra_yml : ""
  ]

  set = concat(
    [
      {
        name  = "adminUser"
        value = var.grafana_admin_user
      },
      {
        name  = "adminPassword"
        value = var.grafana_admin_password != "" ? var.grafana_admin_password : random_password.grafana_admin_password[0].result
      }
    ]
  )
}
