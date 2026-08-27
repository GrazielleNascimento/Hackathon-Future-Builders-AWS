variable "table_name" {
  type        = string
  description = "Nome da tabela DynamoDB"
}

variable "tags" {
  type        = map(string)
  description = "Tags para recursos AWS"
  default     = {}
}
