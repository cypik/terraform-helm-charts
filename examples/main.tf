provider "aws" {
  region = local.region
}

locals {
  name                  = "testing"
  environment           = "eks"
  region                = "us-east-1"
  vpc_cidr_block        = module.vpc.vpc_cidr_block
  additional_cidr_block = "172.16.0.0/16"
}

module "vpc" {
  source      = "cypik/vpc/aws"
  version     = "1.0.5"
  name        = "${local.name}-vpc"
  environment = local.environment
  cidr_block  = "10.10.0.0/16"
}

module "subnets" {
  source              = "cypik/subnet/aws"
  version             = "1.0.7"
  name                = "${local.name}-subnet"
  environment         = local.environment
  nat_gateway_enabled = true
  single_nat_gateway  = true
  availability_zones  = ["${local.region}a", "${local.region}b", "${local.region}c"]
  vpc_id              = module.vpc.vpc_id
  type                = "public-private"
  igw_id              = module.vpc.igw_id
  cidr_block          = local.vpc_cidr_block
  extra_public_tags = {
    "kubernetes.io/cluster/${module.eks.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                           = "1"
  }

  extra_private_tags = {
    "kubernetes.io/cluster/${module.eks.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                  = "1"
  }
}

module "ssh" {
  source      = "cypik/security-group/aws"
  version     = "1.0.4"
  name        = "${local.name}-ssh"
  environment = local.environment
  vpc_id      = module.vpc.vpc_id
  new_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [local.vpc_cidr_block, local.additional_cidr_block]
    description = "Allow ssh traffic."
    },
    {
      rule_count  = 2
      from_port   = 3306
      protocol    = "tcp"
      to_port     = 3306
      cidr_blocks = [local.vpc_cidr_block, local.additional_cidr_block]
      description = "Allow ssh traffic."
    }
  ]

  ## EGRESS Rules
  new_sg_egress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh outbound traffic."
  }]
}

module "http_https" {
  source      = "cypik/security-group/aws"
  version     = "1.0.4"
  name        = "${local.name}-http-https"
  environment = local.environment
  vpc_id      = module.vpc.vpc_id
  ## INGRESS Rules
  new_sg_ingress_rules_with_cidr_blocks = [
    {
      rule_count  = 2
      from_port   = 80
      protocol    = "tcp"
      to_port     = 80
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow http traffic."
    },
    {
      rule_count  = 3
      from_port   = 443
      protocol    = "tcp"
      to_port     = 443
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow https traffic."
    }
  ]

  ## EGRESS Rules
  new_sg_egress_rules_with_cidr_blocks = [{
    rule_count       = 1
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow all traffic."
    }
  ]
}

module "kms" {
  source              = "cypik/kms/aws"
  version             = "1.0.4"
  name                = "${local.name}-kms"
  environment         = local.environment
  enabled             = true
  description         = "KMS key for EBS of EKS nodes"
  enable_key_rotation = false
  policy              = data.aws_iam_policy_document.kms.json
}

data "aws_iam_policy_document" "kms" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

data "aws_caller_identity" "current" {}


module "eks" {
  source      = "cypik/eks/aws"
  version     = "1.0.8"
  enabled     = true
  name        = local.name
  environment = local.environment

  # EKS
  kubernetes_version     = "1.35"
  endpoint_public_access = true
  # Networking
  vpc_id                            = module.vpc.vpc_id
  subnet_ids                        = module.subnets.private_subnet_id
  allowed_security_groups           = [module.ssh.security_group_id]
  eks_additional_security_group_ids = [module.ssh.security_group_id, module.http_https.security_group_id]
  allowed_cidr_blocks               = [local.vpc_cidr_block]

  managed_node_group_defaults = {
    subnet_ids                          = module.subnets.private_subnet_id
    nodes_additional_security_group_ids = [module.ssh.security_group_id]
    tags = {
      "kubernetes.io/cluster/${module.eks.cluster_name}" = "shared"
      "k8s.io/cluster/${module.eks.cluster_name}"        = "shared"
    }
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = 32
          volume_type = "gp3"
          iops        = 3000
          throughput  = 150
          encrypted   = true
          kms_key_id  = module.kms.key_arn
        }
      }
    }
  }

  managed_node_group = {
    ON_DEMAND = {
      name           = "${module.eks.cluster_name}-critical-node"
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3a.medium"]
    }

  }

  apply_config_map_aws_auth = false
}

resource "null_resource" "kubeconfig_setup" {
  depends_on = [module.eks]
  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig \
        --name ${module.eks.cluster_name} \
        --region ${local.region} \
        --kubeconfig ${path.module}/Kubeconfig
      echo "KUBECONFIG created at ${path.module}/Kubeconfig"
    EOT
  }

}
provider "kubernetes" {
  config_path = "${path.module}/Kubeconfig"
}
provider "helm" {
  kubernetes = {
    config_path = "${path.module}/Kubeconfig"
  }
}


module "helm-charts" {
  source     = "./../"
  depends_on = [module.eks, null_resource.kubeconfig_setup]

  ## nginx ingress
  nginx_ingress_enabled = true

  ## cert manager
  cert_manager_enabled = true
  cert_manager_email   = "example@gmail.com"

  # grafana
  grafana_enabled       = true
  grafana_ingress_hosts = ["grafana.opsstation.com"]
  # grafana_acm_certificate_arn = "arn:aws:acm:us-east-1:xxxxxxxxxxxx:certificate/cc7933b1-d4e3-4be1-9b16-xxxxxxxx"
  grafana_loki_enabled = true
  prometheus_enabled   = true

  # loki_custom_values = templatefile("${path.module}/loki_custom_values.yaml", {})
  # alb ingress
  alb_ingress_enabled = false

  # keda
  keda_enabled = false

  # karpenter
  karpenter_enabled = false

  # calico
  calico_enabled = false

  # csi secrets
  csi_secrets_store_enabled = false
  csi_enabled_namespaces    = ["csi-secrets"]

  # metrics server
  metrics_server_enabled = false

  # MySQL exporter - works on any cloud (AWS/Azure/GCP), scrapes MySQL metrics for Prometheus
  mysql_exporter_enabled = true
  db_endpoint            = ""
  db_exporter_password   = "esfsgcGdf23awGAhdxtfjm"

  # CloudWatch integration - AWS only, set false on Azure/GCP
  rds_cloudwatch_datasource_enabled = true
  region                            = local.region

  # Node Exporter dashboard - Grafana dashboard 1860, requires Prometheus + node-exporter running
  node_exporter_dashboard_enabled = true

  cluster_name        = tostring(module.eks.cluster_name)
  vpc_id              = module.vpc.vpc_id # vpc_id is required only when ALB Ingress Controller is enabled (alb_ingress_enabled = true)
  eks_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
}
