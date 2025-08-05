
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
        Sid    = "Karpenter"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ec2:DescribeImages",
          "ec2:RunInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateTags",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:DescribeSpotPriceHistory",
          "pricing:GetProducts"
        ]
        Resource = "*"
      },
      {
        Sid      = "ConditionalEC2Termination"
        Effect   = "Allow"
        Action   = "ec2:TerminateInstances"
        Resource = "*"
        Condition = {
          StringLike = {
            "ec2:ResourceTag/karpenter.sh/nodepool" = "*"
          }
        }
      },
      {
        Sid      = "PassNodeIAMRole"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/KarpenterNodeRole-${var.cluster_name}"
      },
      {
        Sid      = "EKSClusterEndpointLookup"
        Effect   = "Allow"
        Action   = "eks:DescribeCluster"
        Resource = "arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"
      },
      {
        Sid    = "AllowScopedInstanceProfileCreationActions"
        Effect = "Allow"
        Action = [
          "iam:CreateInstanceProfile"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}" = "owned",
            "aws:RequestTag/topology.kubernetes.io/region"             = "${data.aws_region.current.name}"
          }
          StringLike = {
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass" = "*"
          }
        }
      },
      {
        Sid    = "AllowScopedInstanceProfileTagActions"
        Effect = "Allow"
        Action = [
          "iam:TagInstanceProfile"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}" = "owned",
            "aws:ResourceTag/topology.kubernetes.io/region"             = "${data.aws_region.current.name}",
            "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"  = "owned",
            "aws:RequestTag/topology.kubernetes.io/region"              = "${data.aws_region.current.name}"
          }
          StringLike = {
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass" = "*",
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass"  = "*"
          }
        }
      },
      {
        Sid    = "AllowScopedInstanceProfileActions"
        Effect = "Allow"
        Action = [
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}" = "owned",
            "aws:ResourceTag/topology.kubernetes.io/region"             = "${data.aws_region.current.name}"
          }
          StringLike = {
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass" = "*"
          }
        }
      },
      {
        Sid      = "AllowInstanceProfileReadActions"
        Effect   = "Allow"
        Action   = "iam:GetInstanceProfile"
        Resource = "*"
      }
    ]
  })
}


# ---------- Karpenter Node IAM Role ----------


resource "aws_iam_role" "karpenter_node" {
  count = var.enabled_karpenter ? 1 : 0
  name  = "KarpenterNodeRole-${var.cluster_name}"

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
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = "1.6.1"
  create_namespace = true

  set = [
    {
      name  = "settings.clusterName"
      value = data.aws_eks_cluster.this.name
    },
    {
      name  = "settings.clusterEndpoint"
      value = data.aws_eks_cluster.this.endpoint
    },
    {
      name  = "settings.aws.defaultInstanceProfile"
      value = aws_iam_instance_profile.karpenter_node[0].name
    },
    {
      name  = "settings.aws.interruptionQueueName"
      value = aws_sqs_queue.karpenter_interruption[0].name
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.karpenter[0].arn
      type  = "string"
    },
    {
      name  = "controller.nodeSelector.eks\\.amazonaws\\.com/compute-type"
      value = "ec2"
    },


  ]
}


