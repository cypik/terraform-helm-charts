data "aws_eks_cluster" "cluster" {
  count = var.alb_ingress_enabled ? 1 : 0
  name  = var.cluster_name
}

data "aws_eks_cluster_auth" "auth" {
  count = var.alb_ingress_enabled ? 1 : 0
  name  = var.cluster_name
}

data "aws_iam_openid_connect_provider" "oidc-alb" {
  count = var.alb_ingress_enabled ? 1 : 0
  url   = data.aws_eks_cluster.cluster[0].identity[0].oidc[0].issuer
}

resource "aws_iam_policy" "alb_ingress_controller" {
  count       = var.alb_ingress_enabled ? 1 : 0
  name        = "${var.cluster_name}-alb-ingress-controller-policy"
  description = "Policy for ALB Ingress Controller"
  policy      = file("${path.module}/alb-iam_policy.json")
}

resource "aws_iam_role" "alb_ingress_controller" {
  count = var.alb_ingress_enabled ? 1 : 0
  name  = "${var.cluster_name}-alb-ingress-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.oidc-alb[0].arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.cluster[0].identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_ingress_attachment" {
  count      = var.alb_ingress_enabled ? 1 : 0
  role       = aws_iam_role.alb_ingress_controller[0].name
  policy_arn = aws_iam_policy.alb_ingress_controller[0].arn
}

resource "kubernetes_service_account" "aws_lb_controller_sa" {
  count = var.alb_ingress_enabled ? 1 : 0
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_ingress_controller[0].arn
    }
  }

  depends_on = [aws_iam_role.alb_ingress_controller]
}

resource "helm_release" "aws_load_balancer_controller" {
  count      = var.alb_ingress_enabled ? 1 : 0
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.1"

  depends_on = [kubernetes_service_account.aws_lb_controller_sa]

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "region"
      value = var.region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    }
  ]
}
