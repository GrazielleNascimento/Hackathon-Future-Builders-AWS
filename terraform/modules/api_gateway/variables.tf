variable "api_name" {
  description = "Nome da API Gateway"
  type        = string
}

variable "lambda_leads_arn" {
  description = "ARN da Lambda de captura de leads"
  type        = string
}

variable "lambda_leads_name" {
  description = "Nome da Lambda de captura de leads"
  type        = string
}

variable "aws_region" {
  description = "Região AWS"
  type        = string
}
