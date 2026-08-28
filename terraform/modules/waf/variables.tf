variable "waf_name" {
  description = "Nome da Web ACL do WAF"
  type        = string
  default     = "wizard-waf-global"
}

variable "rate_limit" {
  description = "Limite de requisições por IP a cada 5 minutos (mínimo 100)"
  type        = number
  default     = 100
}

variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {}
}