resource "helm_release" "prometheus" {
  count = var.prometheus_enabled ? 1 : 0

  chart            = "prometheus"
  name             = "prometheus"
  namespace        = "prometheus"
  create_namespace = true
  repository       = "https://prometheus-community.github.io/helm-charts"
  version          = var.prometheus_version

  values = compact([
    file("${path.module}/prometheus_additional_scrape_config.yml"),
    var.prometheus_custom_values != null ? var.prometheus_custom_values : null
  ])


  set = concat(
    [
      {
        name  = "podSecurityPolicy.enabled"
        value = var.prometheus_pod_security_policy_enabled
      },
      {
        name  = "server.retention"
        value = var.prometheus_server_retention
      },
      {
        name  = "server.persistentVolume.enabled"
        value = var.prometheus_persistence_storage
      },
      {
        name  = "server.persistentVolume.storageClass"
        value = var.prometheus_storage_class != null ? var.prometheus_storage_class : var.storage_class
      }
    ],
    length(var.pushgateway_ingress_host) > 0 ? [
      {
        name = "values"
        value = templatefile("${path.module}/prometheus.yml", {
          PUSH_GATEWAY_INGRESS_HOSTS = var.pushgateway_ingress_host
        })
      }
    ] : [],
    var.prometheus_persistence_storage != false ? [
      {
        name  = "server.persistentVolume.existingClaim"
        value = var.prometheus_persistent_volume_existing_claim
      },
      {
        name  = "server.persistentVolume.size"
        value = var.prometheus_persistent_volume_size
      }
    ] : [],
    [
      {
        name  = "alertmanager.persistence.enabled"
        value = var.alertmanager_persistence_enabled
      }
    ]
  )
}