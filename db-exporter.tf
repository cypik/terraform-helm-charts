resource "helm_release" "db_mysql_exporter" {
  count = var.mysql_exporter_enabled ? 1 : 0

  name             = "db-mysql-exporter"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus-mysql-exporter"
  namespace        = "monitoring"
  version          = var.mysql_exporter_version
  create_namespace = true


  values = [
    yamlencode({
      mysql = {
        host = split(":", var.db_endpoint)[0]
        user = var.db_username
        pass = var.db_exporter_password
        port = length(split(":", var.db_endpoint)) > 1 ? tonumber(split(":", var.db_endpoint)[1]) : 3306
      }

      serviceMonitor = {
        enabled   = false
        namespace = "monitoring"
      }
      annotations = {
        "prometheus.io/scrape" = "true"
        "prometheus.io/port"   = "9104"
        "prometheus.io/path"   = "/metrics"
      }
    })
  ]
}


resource "aws_iam_policy" "cloudwatch_exporter_policy" {
  count = var.rds_cloudwatch_datasource_enabled && length(var.cluster_name) > 0 ? 1 : 0

  name = "cloudwatch-exporter-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "cloudwatch_exporter_role" {
  count = var.rds_cloudwatch_datasource_enabled && length(var.cluster_name) > 0 ? 1 : 0

  name = "cloudwatch-exporter-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.eks[0].arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.eks_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:monitoring:cloudwatch-exporter"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {
  count = var.rds_cloudwatch_datasource_enabled && length(var.cluster_name) > 0 ? 1 : 0

  role       = aws_iam_role.cloudwatch_exporter_role[0].name
  policy_arn = aws_iam_policy.cloudwatch_exporter_policy[0].arn
}

resource "aws_iam_policy" "grafana_cloudwatch_policy" {
  count = var.grafana_enabled && var.rds_cloudwatch_datasource_enabled && length(var.cluster_name) > 0 ? 1 : 0

  name = "grafana-cloudwatch-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:GetLogGroupFields",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "tag:GetResources"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "grafana_cloudwatch_role" {
  count = var.grafana_enabled && var.rds_cloudwatch_datasource_enabled && length(var.cluster_name) > 0 ? 1 : 0

  name = "grafana-cloudwatch-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.eks[0].arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.eks_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:grafana:grafana"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "grafana_cloudwatch_attach" {
  count = var.grafana_enabled && var.rds_cloudwatch_datasource_enabled && length(var.cluster_name) > 0 ? 1 : 0

  role       = aws_iam_role.grafana_cloudwatch_role[0].name
  policy_arn = aws_iam_policy.grafana_cloudwatch_policy[0].arn
}

resource "helm_release" "cloudwatch_exporter" {
  count = var.rds_cloudwatch_datasource_enabled && length(var.cluster_name) > 0 ? 1 : 0

  name             = "cloudwatch-exporter"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus-cloudwatch-exporter"
  namespace        = "monitoring"
  create_namespace = true
  version          = var.cloudwatch_exporter_version

  values = [yamlencode({
    serviceAccount = {
      create = true
      name   = "cloudwatch-exporter"
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.cloudwatch_exporter_role[0].arn
      }
    }

    # Config must be a YAML string, not a map
    config = yamlencode({
      region = var.region
      metrics = [
        {
          aws_namespace   = "AWS/RDS"
          aws_metric_name = "CPUUtilization"
          aws_dimensions  = ["DBInstanceIdentifier"]
          aws_statistics  = ["Average"]
        },
        {
          aws_namespace   = "AWS/RDS"
          aws_metric_name = "FreeableMemory"
          aws_dimensions  = ["DBInstanceIdentifier"]
          aws_statistics  = ["Average"]
        },
        {
          aws_namespace   = "AWS/RDS"
          aws_metric_name = "FreeStorageSpace"
          aws_dimensions  = ["DBInstanceIdentifier"]
          aws_statistics  = ["Average"]
        },
        {
          aws_namespace   = "AWS/RDS"
          aws_metric_name = "DatabaseConnections"
          aws_dimensions  = ["DBInstanceIdentifier"]
          aws_statistics  = ["Average"]
        },
        {
          aws_namespace   = "AWS/RDS"
          aws_metric_name = "ReadIOPS"
          aws_dimensions  = ["DBInstanceIdentifier"]
          aws_statistics  = ["Average"]
        },
        {
          aws_namespace   = "AWS/RDS"
          aws_metric_name = "WriteIOPS"
          aws_dimensions  = ["DBInstanceIdentifier"]
          aws_statistics  = ["Average"]
        },
        {
          aws_namespace   = "AWS/RDS"
          aws_metric_name = "ReadLatency"
          aws_dimensions  = ["DBInstanceIdentifier"]
          aws_statistics  = ["Average"]
        },
        {
          aws_namespace   = "AWS/RDS"
          aws_metric_name = "WriteLatency"
          aws_dimensions  = ["DBInstanceIdentifier"]
          aws_statistics  = ["Average"]
        },
        {
          aws_namespace   = "AWS/RDS"
          aws_metric_name = "ReadThroughput"
          aws_dimensions  = ["DBInstanceIdentifier"]
          aws_statistics  = ["Average"]
        },
        {
          aws_namespace   = "AWS/RDS"
          aws_metric_name = "WriteThroughput"
          aws_dimensions  = ["DBInstanceIdentifier"]
          aws_statistics  = ["Average"]
        },
        {
          aws_namespace   = "AWS/RDS"
          aws_metric_name = "DiskQueueDepth"
          aws_dimensions  = ["DBInstanceIdentifier"]
          aws_statistics  = ["Average"]
        },
        {
          aws_namespace   = "AWS/RDS"
          aws_metric_name = "SwapUsage"
          aws_dimensions  = ["DBInstanceIdentifier"]
          aws_statistics  = ["Average"]
        },
        {
          aws_namespace   = "AWS/RDS"
          aws_metric_name = "NetworkReceiveThroughput"
          aws_dimensions  = ["DBInstanceIdentifier"]
          aws_statistics  = ["Average"]
        },
        {
          aws_namespace   = "AWS/RDS"
          aws_metric_name = "NetworkTransmitThroughput"
          aws_dimensions  = ["DBInstanceIdentifier"]
          aws_statistics  = ["Average"]
        },
        {
          aws_namespace   = "AWS/RDS"
          aws_metric_name = "ReplicaLag"
          aws_dimensions  = ["DBInstanceIdentifier"]
          aws_statistics  = ["Average"]
        }
      ]
    })
  })]
}