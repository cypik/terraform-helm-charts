resource "helm_release" "keda" {
  count            = var.enable_keda ? 1 : 0
  name             = var.keda_name
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  namespace        = var.keda_namespace
  create_namespace = true
  version          = var.keda_chart_version
  timeout          = 600

  values = [
    yamlencode({
      prometheus = {
        metricServer = {
          enabled = true
        }
      }
    })
  ]

  depends_on = [helm_release.metrics_server]
}
