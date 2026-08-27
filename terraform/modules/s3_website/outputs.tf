output "primary_bucket_id" {
  description = "ID do bucket primário"
  value       = aws_s3_bucket.primary.id
}

output "primary_bucket_arn" {
  description = "ARN do bucket primário"
  value       = aws_s3_bucket.primary.arn
}

output "primary_bucket_regional_domain_name" {
  description = "Domain name regional para configurar a origem no CloudFront"
  value       = aws_s3_bucket.primary.bucket_regional_domain_name
}

output "failover_bucket_id" {
  description = "ID do bucket de contingência"
  value       = aws_s3_bucket.failover.id
}

output "failover_bucket_arn" {
  description = "ARN do bucket de contingência"
  value       = aws_s3_bucket.failover.arn
}

output "failover_bucket_regional_domain_name" {
  description = "Domain name regional para configurar a origem de failover no CloudFront"
  value       = aws_s3_bucket.failover.bucket_regional_domain_name
}