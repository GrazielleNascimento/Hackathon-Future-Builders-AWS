variable "function_name" {
  type        = string
  description = "Nome da função Lambda"
}

variable "handler" {
  type        = string
  description = "Handler da função Lambda (ex: funcao.lambda_handler)"
}

variable "runtime" {
  type        = string
  description = "Runtime da Lambda"
  default     = "python3.12"
}

variable "role_arn" {
  type        = string
  description = "ARN da role IAM para a Lambda"
}

variable "filename" {
  type        = string
  description = "Caminho do arquivo zip da Lambda"
}

variable "environment_variables" {
  type        = map(string)
  description = "Variáveis de ambiente para a Lambda"
  default     = {}
}

variable "table_name" {
  description = "Nome da tabela DynamoDB usada pela Lambda"
  type        = string
}