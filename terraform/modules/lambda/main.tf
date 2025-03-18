data "archive_file" "lambda" {
  type        = "zip"
  source_file = "index.js"
  output_path = "lambda.zip"
}


resource "aws_lambda_function" "lambda" {
  for_each      = toset(var.env)
  filename      = data.archive_file.lambda.output_path
  function_name = "lambda-test-${each.value}"
  role          =  var.lambda_role_ids["${each.value}"]
  handler       = "index.handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime = "nodejs18.x"

  memory_size                   = 1024
  timeout                        = 30
  reserved_concurrent_executions = 10

  tags = merge(
    var.common_tags,
    {
      Environment = "${each.value}"
    }
  )

}


resource "aws_lambda_event_source_mapping" "mapping-test" {
  for_each      = toset(var.env)
  event_source_arn = var.sqs_queue_ids["${each.value}"]
  function_name    = aws_lambda_function.lambda["${each.value}"].arn
  batch_size       = 10
  enabled          = true
  tags = merge(
    var.common_tags,
    {
      Environment = "${each.value}"
    }
  )
}
resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each      = toset(var.env)
  name              = "/aws/lambda/lambda-test-${each.value}"
  retention_in_days = 7
}