# Cluster and Auth Data

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}



# IAM Role for Karpenter Controller
resource "aws_iam_role" "karpenter" {
  count = var.enabled_karpenter ? 1 : 0
  name  = "karpenter-controller-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.oidc.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:karpenter:karpenter",
          "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}



# IAM Policy for Karpenter Controller
resource "aws_iam_role_policy" "karpenter_controller_policy" {
  count = var.enabled_karpenter ? 1 : 0
  name  = "karpenter-controller-policy"
  role  = aws_iam_role.karpenter[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "ec2:TerminateInstances",
          "ec2:Describe*",
          "ssm:GetParameter",
          "iam:PassRole",
          "pricing:GetProducts",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions",
          "eks:DescribeCluster"
        ],
        Resource = "*"
      }
    ]
  })
}

# ---------- Karpenter Node IAM Role ----------


resource "aws_iam_role" "karpenter_node" {
  count = var.enabled_karpenter ? 1 : 0
  name  = "karpenter-node-role-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}



# ---------- Attach AWS Managed Policies to Node Role ----------
resource "aws_iam_role_policy_attachment" "karpenter_node_managed_policies" {
  count = var.enabled_karpenter ? 4 : 0
  role  = aws_iam_role.karpenter_node[0].name
  policy_arn = element([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ], count.index)
}


# Instance Profile for EC2 Nodes
resource "aws_iam_instance_profile" "karpenter_node" {
  count = var.enabled_karpenter ? 1 : 0
  name  = "karpenter-instance-profile-${var.cluster_name}"
  role  = aws_iam_role.karpenter_node[0].name
}

# SQS Queue for Spot Interruption Handling
resource "aws_sqs_queue" "karpenter_interruption" {
  count = var.enabled_karpenter ? 1 : 0
  name  = "${var.cluster_name}-karpenter-interruption"
}




# Helm Chart Deployment for Karpenter
resource "helm_release" "karpenter" {
  count            = var.enabled_karpenter ? 1 : 0
  name             = "karpenter"
  namespace        = "karpenter"
  repository       = "https://charts.karpenter.sh"
  chart            = "karpenter"
  version          = "0.16.1"
  create_namespace = true


  set {
    name  = "settings.clusterName"
    value = data.aws_eks_cluster.this.name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = data.aws_eks_cluster.this.endpoint
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter_node[0].name
  }

  set {
    name  = "settings.aws.interruptionQueueName"
    value = aws_sqs_queue.karpenter_interruption[0].name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter[0].arn
    type  = "string"
  }


  set {
    name  = "controller.nodeSelector.eks\\.amazonaws\\.com/compute-type"
    value = "ec2"
  }

  set {
    name  = "controller.tolerations[0].key"
    value = "eks.amazonaws.com/compute-type"
  }

  set {
    name  = "controller.tolerations[0].operator"
    value = "NotEqual"
  }

  set {
    name  = "controller.tolerations[0].value"
    value = "fargate"
  }

  set {
    name  = "controller.tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "128Mi"
  }



  #####################

  # Pod ke env vars ke liye (container ke andar use karne ke liye)
  set {
    name  = "controller.env[0].name"
    value = "CLUSTER_NAME"
  }

  set {
    name  = "controller.env[0].value"
    value = data.aws_eks_cluster.this.name
  }

  set {
    name  = "controller.env[1].name"
    value = "CLUSTER_ENDPOINT"
  }

  set {
    name  = "controller.env[1].value"
    value = data.aws_eks_cluster.this.endpoint
  }




  # 🔥 Add these to fix cert issue
  set {
    name  = "webhook.enabled"
    value = "false"
  }

  set {
    name  = "webhook.certificate.certManager.enabled"
    value = "false"
  }

  set {
    name  = "webhook.certificate.custom.enabled"
    value = "false"
  }

  set {
    name  = "webhook.certificate.selfSigned.enabled"
    value = "false"
  }
}


