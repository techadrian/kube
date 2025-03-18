output "sqs_queue_ids" {
  value = { for key, role in aws_sqs_queue.sqs-test : key => role.arn }
}

