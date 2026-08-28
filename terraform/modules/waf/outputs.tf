output "web_acl_arn" {
  description = "ARN da Web ACL para associar ao CloudFront"
  value       = aws_wafv2_web_acl.main.arn
}

output "web_acl_id" {
  value = aws_wafv2_web_acl.main.id
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.waf_logs.name
}