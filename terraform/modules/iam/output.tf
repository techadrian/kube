output "lambda_role_ids" {
  value = { for key, role in aws_iam_role.lambda_role : key => role.arn }
}

