output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.site.id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.site.domain_name
}

output "cloudfront_arn" {
  value = aws_cloudfront_distribution.site.arn
}

output "cloudfront_hosted_zone_id" {
  description = "Zone ID fixo do CloudFront para registros Alias no Route 53"
  value       = aws_cloudfront_distribution.site.hosted_zone_id
}