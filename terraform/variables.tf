variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "aws_region_primary" {
  description = "Região primária para o S3 (São Paulo)"
  type        = string
  default     = "sa-east-1"
}

# Role IAM
variable "role_name" {
  description = "Nome da role IAM para Lambda"
  type        = string
  default     = "my_lambda_role"
}

# Lambda: hello_terraform
variable "lambda_hello_name" {
  description = "Nome da função Lambda hello_terraform"
  type        = string
  default     = "hello_terraform_lambda"
}

variable "lambda_hello_handler" {
  description = "Handler da função Lambda hello_terraform"
  type        = string
  default     = "hello_terraform.lambda_handler"
}

variable "lambda_hello_zip_path" {
  description = "Caminho para o arquivo zip da Lambda hello_terraform"
  type        = string
  default     = "../dist/hello_terraform_lambda.zip"
}

# Lambda: captura de leads
variable "lambda_lead_capture_name" {
  description = "Nome da função Lambda de captura de leads"
  type        = string
  default     = "wizard_lead_capture_lambda"
}

variable "lambda_lead_capture_handler" {
  description = "Handler da função Lambda de captura de leads"
  type        = string
  default     = "add_item.lambda_handler"
}

variable "lambda_lead_capture_zip_path" {
  description = "Caminho para o arquivo zip da Lambda de captura de leads"
  type        = string
  default     = "../dist/lead_capture.zip"
}

# Runtime compartilhado entre as funções
variable "lambda_runtime" {
  description = "Runtime da Lambda"
  type        = string
  default     = "python3.9"
}

# DynamoDB
variable "leads_table_name" {
  description = "Nome da tabela DynamoDB"
  type        = string
  default     = "wizard_leads"
}

# Tags
variable "tags" {
  description = "Tags para recursos AWS"
  type        = map(string)
  default     = {}
}
