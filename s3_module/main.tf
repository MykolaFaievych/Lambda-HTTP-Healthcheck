resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.env}-s3bucket"
  acl    = "private"

  tags = {
    Name = "${var.env}-s3bucket"
  }
}