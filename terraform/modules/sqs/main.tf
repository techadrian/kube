
resource "aws_sqs_queue" "sqs-dlq-test" {
  for_each      = toset(var.env)
  name = "sqs-test-${each.value}-dlq"
  message_retention_seconds = 1209600
  tags = merge(
    var.common_tags,
    {
      Environment = "${each.value}"
    }
  )
}


resource "aws_sqs_queue" "sqs-test" {
  for_each      = toset(var.env)
  name = "sqs-test-${each.value}-queue"
  visibility_timeout_seconds = 30
  message_retention_seconds = 86400
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs-dlq-test[each.value].arn
    maxReceiveCount     = 5
  })
  kms_master_key_id = "alias/aws/sqs"
  tags = merge(
    var.common_tags,
    {
      Environment = "${each.value}"
    }
  )
}