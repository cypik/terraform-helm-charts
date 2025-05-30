
module "helm-charts" {
  source               = "./../."
  enable_nginx         = true
  enable_keda          = false
  grafana_enabled      = true
  grafana_loki_enabled = true
  prometheus_enabled   = true
  cert_manager_enabled = true
  cert_manager_email   = "example@gmail.com"


}

