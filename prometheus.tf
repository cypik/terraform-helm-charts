resource "helm_release" "prometheus" {
  count = var.prometheus_enabled ? 1 : 0

  chart            = "prometheus"
  name             = "prometheus"
  namespace        = "prometheus"
  create_namespace = true
  repository       = "https://prometheus-community.github.io/helm-charts"
  version          = var.prometheus_version

  values = length(var.prometheus_additional_scrape_configs) > 0 ? [
    templatefile("${path.module}/prometheus_additional_scrape_config.yml", {
      SCRAPE_CONFIG = var.prometheus_additional_scrape_configs,
    }),
  ] : []

  set {
    name  = "podSecurityPolicy.enabled"
    value = true
  }

  set {
    name  = "server.retention"
    value = "1d"
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = var.prometheus_persistence_storage
  }

  set {
    name  = "server.persistentVolume.storageClass"
    value = var.storage_class
  }

  dynamic "set" {
    for_each = length(var.pushgateway_ingress_host) > 0 ? [
      {
        name = "values"
        value = templatefile("${path.module}/prometheus.yml", {
          PUSH_GATEWAY_INGRESS_HOSTS = var.pushgateway_ingress_host
        })
      }
    ] : []

    content {
      name  = set.value.name
      value = set.value.value
    }
  }


  ## Prometheus server data Persistent Volume existing claim name
  ## Requires server.persistentVolume.enabled: true
  ## If defined, PVC must be created manually before volume will be bound
  ## Example if we want to use EFS, create storage class and pvc and add the
  ## claim name here
  dynamic "set" {
    for_each = var.prometheus_persistence_storage != false ? [1] : []
    content {
      name  = "server.persistentVolume.existingClaim"
      value = ""
    }
  }

  dynamic "set" {
    for_each = var.prometheus_persistence_storage != false ? [1] : []
    content {
      name  = "server.persistentVolume.size"
      value = "8Gi"
    }
  }

  set {
    name  = "alertmanager.persistence.enabled"
    value = false
  }

}
