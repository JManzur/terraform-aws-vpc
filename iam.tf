# S3 VPC Flow Logs IAM Policy Document
data "aws_iam_policy_document" "s3" {
  count = var.vpc_flow_logs_destination == "S3" ? 1 : 0
  statement {
    sid    = "SendVPCFlowLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:CreateLogDelivery",
      "logs:DeleteLogDelivery"
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }

  statement {
    sid    = "VPCFlowLogsBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetBucketAcl",
      "s3:PutBucketPolicy",
      "s3:GetBucketPolicy"
    ]
    resources = [
      "arn:aws:s3:::${aws_vpc.vpc.id}-flow-logs",
      "arn:aws:s3:::${aws_vpc.vpc.id}-flow-logs/*",
    ]
  }
}

# CloudWatch VPC Flow Logs IAM Policy Document
data "aws_iam_policy_document" "cloudwatch" {
  count = var.vpc_flow_logs_destination == "CloudWatch" ? 1 : 0
  statement {
    sid    = "SendVPCFlowLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:CreateLogDelivery",
      "logs:DeleteLogDelivery"
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }
}

# VPC Flow Logs IAM Role Policy Document
data "aws_iam_policy_document" "vpc_fl_role_source" {
  statement {
    sid    = "VPCFlowLogs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# VPC Flow Logs IAM Policy
resource "aws_iam_policy" "vpc_fl_policy" {
  name        = lower("${var.name_prefix}-vpc-flow-logs-policy")
  path        = "/"
  description = "VPC Flow Logs Policy"
  policy      = var.vpc_flow_logs_destination == "S3" ? data.aws_iam_policy_document.s3[0].json : data.aws_iam_policy_document.cloudwatch[0].json
  tags        = { Name = lower("${var.name_prefix}-vpc-flow-logs-policy") }
}

# VPC Flow Logs IAM Role
resource "aws_iam_role" "vpc_fl_policy_role" {
  name               = lower("${var.name_prefix}-vpc-flow-logs-role")
  assume_role_policy = data.aws_iam_policy_document.vpc_fl_role_source.json
  tags               = { Name = lower("${var.name_prefix}-vpc-flow-logs-role") }
}

# Attach VPC Flow Logs Role and Policy
resource "aws_iam_role_policy_attachment" "vpc_fl_attach" {
  role       = aws_iam_role.vpc_fl_policy_role.name
  policy_arn = aws_iam_policy.vpc_fl_policy.arn
}