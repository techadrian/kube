
resource "aws_dynamodb_table" "dynamo-test" {

  for_each                    = toset(var.env)
  name                        = "dynamo-test-${each.value}-db"
  billing_mode                = "PAY_PER_REQUEST"
  hash_key                    = "ID"
  range_key                   = "userId"
  deletion_protection_enabled = true

  attribute {
    name = "ID"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  ttl {
    attribute_name = "TTL"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = true
  }
  tags = merge(
    var.common_tags,
    {
      Environment = "${each.value}"
    }
  )
}