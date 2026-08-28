provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "sa_east_1"
  region = var.aws_region_primary
}

# ----------------------------------------------------
# 1. MÓDULOS DE BACKEND SERVERLESS & BANCO
# ----------------------------------------------------
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

# ----------------------------------------------------
# 2. SEGURANÇA NA BORDA (AWS WAF)
# ----------------------------------------------------
module "waf" {
  source     = "./modules/waf"
  waf_name   = "wizard-leads-waf"
  rate_limit = 100
  tags       = var.tags
}

# ----------------------------------------------------
# 3. S3 MULTI-REGIÃO (PRIMARY EM SP, FAILOVER NA VIRGÍNIA)
# ----------------------------------------------------
module "s3_website" {
  source        = "./modules/s3_website"
  bucket_prefix = "wizard-g5-site"
  html_filepath = "${path.module}/../index.html"
  tags          = var.tags

  providers = {
    aws.sa_east_1 = aws.sa_east_1
  }
}

# ----------------------------------------------------
# 4. CDN & DISTRIBUIÇÃO GLOBAL (CLOUDFRONT)
# ----------------------------------------------------
module "cloudfront" {
  source = "./modules/cloudfront"

  primary_bucket_regional_domain_name  = module.s3_website.primary_bucket_regional_domain_name
  primary_bucket_arn                   = module.s3_website.primary_bucket_arn
  failover_bucket_regional_domain_name = module.s3_website.failover_bucket_regional_domain_name
  failover_bucket_arn                  = module.s3_website.failover_bucket_arn
  web_acl_id                          = module.waf.web_acl_arn
  tags                                 = var.tags
}

# ----------------------------------------------------
# 5. POLÍTICAS DE ACESSO S3 VIA CLOUDFRONT OAC
# ----------------------------------------------------
# Política no S3 Primário (São Paulo)
resource "aws_s3_bucket_policy" "primary_oac" {
  provider = aws.sa_east_1
  bucket   = module.s3_website.primary_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${module.s3_website.primary_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = module.cloudfront.cloudfront_arn
          }
        }
      }
    ]
  })
}

# Política no S3 Failover (Virgínia)
resource "aws_s3_bucket_policy" "failover_oac" {
  bucket = module.s3_website.failover_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${module.s3_website.failover_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = module.cloudfront.cloudfront_arn
          }
        }
      }
    ]
  })
}