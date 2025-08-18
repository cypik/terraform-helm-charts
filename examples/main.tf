module "helm-charts" {
  source                    = "./../."
  enable_nginx              = false
  enable_keda               = false
  grafana_enabled           = false
  grafana_loki_enabled      = false
  prometheus_enabled        = false
  cert_manager_enabled      = false
  enabled_karpenter         = false
  alb_ingress_enabled       = false
  calico_enabled            = false
  csi_secrets_store_enabled = false
  csi_enabled_namespaces    = ["test"]
  enabled_metrics_server    = false
  cert_manager_email        = "example@gmail.com"
  cluster_name              = tostring(data.aws_eks_cluster.this.name)
  vpc_id                    = data.aws_vpc.vpc.id
  region                    = "eu-west-1"

}

