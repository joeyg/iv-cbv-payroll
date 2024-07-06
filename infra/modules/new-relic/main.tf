data "aws_caller_identity" "current" {}

resource "aws_iam_role" "newrelic_integration" {
  name = "${var.app_name}-${var.environment}-newrelic"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::754728514883:root"
      }
      Condition = {
        StringEquals = {
          "sts:ExternalId" = var.newrelic_account_id
        }
      }
    }]
  })
}

resource "aws_iam_policy" "newrelic_integration" {
  name = "${var.app_name}-${var.environment}-newrelic"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "cloudwatch:GetMetricData",
        "cloudwatch:ListMetrics",
        "ecs:ListClusters",
        "ecs:DescribeClusters",
        "ecs:ListServices",
        "ecs:DescribeServices",
        "ecs:ListTasks",
        "ecs:DescribeTasks",
        "ecs:DescribeTaskDefinition",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetHealth"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "newrelic_integration" {
  role       = aws_iam_role.newrelic_integration.name
  policy_arn = aws_iam_policy.newrelic_integration.arn
}