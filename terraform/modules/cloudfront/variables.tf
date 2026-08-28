variable "primary_bucket_regional_domain_name" {
  description = "Domain name regional do bucket S3 primário"
  type        = string
}

variable "primary_bucket_arn" {
  description = "ARN do bucket S3 primário"
  type        = string
}

variable "failover_bucket_regional_domain_name" {
  description = "Domain name regional do bucket S3 de failover"
  type        = string
}

variable "failover_bucket_arn" {
  description = "ARN do bucket S3 de failover"
  type        = string
}

variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {}
}