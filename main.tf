module "dynamodb" {
  source = "./dynamodb_module"
  env    = var.env
}

module "policy" {
  source = "./policy_module"
  env    = var.env
}

module "sg" {
  source     = "./sg-lambda_module"
  vpc_id     = data.aws_vpc.target_vpc.id
  env        = var.env
  depends_on = [module.policy]
}

module "lambda" {
  source             = "./lambda_module"
  env                = var.env
  iam_role_lambda    = module.policy.lambda_role_arn
  private_subnet_ids = data.aws_subnet_ids.private.ids
  private_sg         = module.sg.lambda_sg
  depends_on         = [module.dynamodb]
}
