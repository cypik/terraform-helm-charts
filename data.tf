## Cluster and Auth Data

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "eks" {
  count = length(var.cluster_name) > 0 ? 1 : 0
  url   = var.eks_oidc_issuer_url
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}