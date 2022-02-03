output "vpc_id" {
  value = data.aws_vpc.target_vpc.id
}
output "vpc_cidr" {
  value = data.aws_vpc.target_vpc.cidr_block
}
output "public_subnet_ids" {
  value = data.aws_subnet_ids.public.ids
}
output "private_subnet_ids" {
  value = data.aws_subnet_ids.private.ids
}