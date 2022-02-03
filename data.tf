# Find specific vpc
data "aws_vpc" "target_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}"]
  }
}
# Find public subnets
data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.target_vpc.id
  tags = {
    Name = "${var.public_subnets_name}"
  }
}

# Find private subnets
data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.target_vpc.id
  tags = {
    Name = "${var.private_subnets_name}"
  }
}