resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.env}-lambda-healthcheck"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "logging_policy" {
  name        = "${var.env}-logging-lambda"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "vpc_policy" {
  name        = "${var.env}-vpc-lambda"
  description = "IAM policy for VPC from a lambda"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface",
                "ec2:AssignPrivateIpAddresses",
                "ec2:UnassignPrivateIpAddresses"
            ],
            "Resource": "*"
        }
    ]
} 
  EOF
}


resource "aws_iam_policy" "ses_policy" {
  name        = "${var.env}-ses-lambda"
  description = "IAM policy for SES from a lambda"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ses:*"
            ],
            "Resource": "*"
        }
    ]
}
  EOF
}
resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.env}-ec2-lambda"
  description = "IAM policy for EC2 from a lambda"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [{
      "Effect": "Allow",
      "Action": [
         "ec2:DescribeInstances", 
         "ec2:DescribeImages",
         "ec2:DescribeTags", 
         "ec2:DescribeSnapshots"
      ],
      "Resource": "*"
   }
   ]
}
  EOF
}

resource "aws_iam_policy" "dynamodb_policy" {
  name        = "${var.env}-dynamodb-lambda"
  description = "IAM policy for DynamoDB from a lambda"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "dynamodb:*",
                "cloudwatch:PutMetricAlarm"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "iam:PassRole"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "iam:PassedToService": [
                        "application-autoscaling.amazonaws.com",
                        "dax.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "replication.dynamodb.amazonaws.com",
                        "dax.amazonaws.com",
                        "dynamodb.application-autoscaling.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
  EOF
}

resource "aws_iam_policy" "s3_bucket_policy" {
  name        = "${var.env}-s3-lambda"
  description = "IAM policy for S3 bucket from a lambda"

  policy = <<EOF
{
    "Version":"2012-10-17",
    "Statement":[
        {
            "Effect":"Allow",
            "Action":[
                "s3:PutObject",
                "s3:ListBucket",
                "s3:PutObjectAcl",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:DeleteObject",
                "cloudwatch:PutMetricAlarm"
            ],
            "Resource": [
              "arn:aws:s3:::${var.env}-s3bucket",
              "arn:aws:s3:::${var.env}-s3bucket/*"
            ]
        }
    ]
    }
  EOF
}

resource "aws_iam_role_policy_attachment" "attach-vpc" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.vpc_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach-dynamodb" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach-logging" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.logging_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach-s3" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.s3_bucket_policy.arn
}


resource "aws_iam_role_policy_attachment" "attach-ses" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.ses_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach-ec2" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}