data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  for_each      = toset(var.env)
  name               = "lambda-test-${each.value}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = merge(
    var.common_tags,
    {
      Environment = "${each.value}"
    }
  )
}

 resource "aws_iam_role_policy" "lambda_logs_policy" {
  for_each      = toset(var.env)
  name = "lambda-permissions-${each.value}"
  role = aws_iam_role.lambda_role[each.value].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
resource "aws_iam_role_policy" "lambda_sqs_policy" {
  for_each      = toset(var.env)
  role = "lambda-test-${each.value}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Effect   = "Allow",
        Resource = var.sqs_queue_ids["${each.value}"]
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_dynamo_policy" {
  for_each      = toset(var.env)
  role = "lambda-test-${each.value}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
        ],
        Effect   = "Allow",
        Resource = var.dynamodb_ids["${each.value}"]
      }
    ]
  })
}