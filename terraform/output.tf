output "api_invoke_url" {
  description = "URL para invocar a API"
  value       = module.api_gateway.invoke_url
}

output "cloudfront_url" {
  description = "URL publica segura da aplicacao no CloudFront"
  value       = "https://${module.cloudfront.cloudfront_domain_name}"
}