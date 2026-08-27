variable "bucket_prefix" {
  description = "Prefixo único para os nomes dos buckets S3"
  type        = string
}

variable "html_filepath" {
  description = "Caminho relativo ou absoluto para o arquivo index.html"
  type        = string
}

variable "tags" {
  description = "Tags padrões aplicadas aos recursos"
  type        = map(string)
  default     = {}
}