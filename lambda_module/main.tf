data "archive_file" "function-zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "healthcheck_lambda" {
  filename         = "lambda_function.zip"
  function_name    = "${var.env}-http-healthcheck"
  role             = var.iam_role_lambda
  timeout          = "10"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.function-zip.output_base64sha256
  runtime          = "python3.7"
  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.private_sg]
  }

  tags = {
    Name = "${var.env}-http-healthcheck"
  }
}
resource "aws_cloudwatch_event_rule" "every_5th_min" {
  name                = "every-5th-min"
  description         = "Trigger every five minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "healthcheck_every_5th_min" {
  target_id = "${var.env}-id"
  rule      = aws_cloudwatch_event_rule.every_5th_min.name
  arn       = aws_lambda_function.healthcheck_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.healthcheck_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_5th_min.arn
}