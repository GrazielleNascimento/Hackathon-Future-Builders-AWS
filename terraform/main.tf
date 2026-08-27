provider "aws" {
  region = var.aws_region
}

module "dynamodb" {
  source = "./modules/dynamodb"

  table_name = var.leads_table_name
  tags       = var.tags
}

module "iam_lambda" {
  source = "./modules/iam"

  role_name          = var.role_name
  dynamodb_table_arn = module.dynamodb.table_arn
}

module "lambda_hello" {
  source = "./modules/lambda"

  function_name = var.lambda_hello_name
  handler       = var.lambda_hello_handler
  runtime       = var.lambda_runtime
  role_arn      = module.iam_lambda.role_arn
  filename      = var.lambda_hello_zip_path
  table_name    = module.dynamodb.table_name
}

module "lambda_lead_capture" {
  source = "./modules/lambda"

  function_name = var.lambda_lead_capture_name
  handler       = var.lambda_lead_capture_handler
  runtime       = var.lambda_runtime
  role_arn      = module.iam_lambda.role_arn
  filename      = var.lambda_lead_capture_zip_path
  table_name    = module.dynamodb.table_name
}

module "api_gateway" {
  source            = "./modules/api_gateway"
  api_name          = "wizard-leads-api"
  lambda_hello_arn  = module.lambda_hello.lambda_arn
  lambda_hello_name = module.lambda_hello.lambda_name
  lambda_leads_arn  = module.lambda_lead_capture.lambda_arn
  lambda_leads_name = module.lambda_lead_capture.lambda_name
  aws_region        = var.aws_region
}

module "s3_website" {
  source        = "./modules/s3_website"
  bucket_prefix = "wizard-g5-site-${var.aws_region}"
  html_filepath = "${path.module}/../index.html"
  tags          = var.tags
}
