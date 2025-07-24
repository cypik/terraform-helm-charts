module "helm-charts" {
  source               = "./../."
  enable_nginx         = false
  enable_keda          = false
  grafana_enabled      = false
  grafana_loki_enabled = false
  prometheus_enabled   = false
  cert_manager_enabled = false
  enabled_karpenter    = false
  cert_manager_email   = "example@gmail.com"
  cluster_name         = tostring(data.aws_eks_cluster.this.name) # if enabled_karpenter


}

