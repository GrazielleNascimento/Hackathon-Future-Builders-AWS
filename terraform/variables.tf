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

# Filas SQS de leads
variable "leads_queue_name" {
  description = "Nome da fila principal de leads"
  type        = string
  default     = "wizard-lead-queue"
}

variable "leads_dlq_name" {
  description = "Nome da DLQ de leads"
  type        = string
  default     = "wizard-lead-dlq"
}

# Tags
variable "tags" {
  description = "Tags para recursos AWS"
  type        = map(string)
  default     = {}
}
