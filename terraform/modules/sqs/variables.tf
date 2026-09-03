variable "queue_name" {
  description = "Nome da fila principal de leads"
  type        = string
}

variable "dlq_name" {
  description = "Nome da fila de mensagens não processadas"
  type        = string
}

variable "tags" {
  description = "Tags dos recursos SQS"
  type        = map(string)
  default     = {}
}
