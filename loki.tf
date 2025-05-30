resource "helm_release" "loki" {
  count            = var.grafana_loki_enabled ? 1 : 0
  chart            = "loki"
  name             = "loki"
  namespace        = "loki"
  create_namespace = true
  repository       = "https://grafana.github.io/helm-charts"
  version          = var.loki_version

  values = [
    templatefile("${path.module}/loki.yaml", {
      storage_class = var.storage_class
    }),
  ]
}

# -------------------------
# Promtail Helm Release
# -------------------------
resource "helm_release" "promtail" {
  count            = var.grafana_loki_enabled ? 1 : 0
  chart            = "promtail"
  name             = "promtail"
  namespace        = "loki"
  create_namespace = true
  repository       = "https://grafana.github.io/helm-charts"
  version          = var.promtail_version

  set {
    name  = "config.logLevel"
    value = "info"
  }

  set {
    name  = "config.serverPort"
    value = "3101"
  }

  set {
    name  = "config.clients[0].url"
    value = "http://loki-gateway.loki.svc.cluster.local/loki/api/v1/push"
  }
}