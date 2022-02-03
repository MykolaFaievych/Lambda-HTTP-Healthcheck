resource "aws_dynamodb_table" "lambda_table" {
  name           = "lambda-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "Address"


  attribute {
    name = "Address"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name = "${var.env}-lambda-table"
  }
}