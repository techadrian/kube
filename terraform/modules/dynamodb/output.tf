output "dynamodb_ids" {
  value = { for key, role in aws_dynamodb_table.dynamo-test : key => role.arn }
}

