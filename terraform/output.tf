output "api_invoke_url" {
  description = "URL para invocar a API"
  value       = module.api_gateway.invoke_url
}

output "cloudfront_url" {
  description = "URL publica segura da aplicacao no CloudFront"
  value       = "https://${module.cloudfront.cloudfront_domain_name}"
}

output "leads_queue_url" {
  description = "URL da fila SQS de leads"
  value       = module.leads_queue.queue_url
}

output "leads_dlq_arn" {
  description = "ARN da DLQ de leads"
  value       = module.leads_queue.dlq_arn
}