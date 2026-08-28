# 1. CloudWatch Log Group para armazenar os logs de bloqueio do WAF
resource "aws_cloudwatch_log_group" "waf_logs" {
  name              = "aws-waf-logs-${var.waf_name}"
  retention_in_days = 7
  tags              = var.tags
}

# 2. Web ACL do AWS WAFv2 (Escopo CLOUDFRONT)
resource "aws_wafv2_web_acl" "main" {
  name        = var.waf_name
  description = "Blindagem WAF para Landing Page e Leads Wizard"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # Regra 1: Rate Limiting (Bloqueio Anti-Spam / Anti-DDoS por IP)
  rule {
    name     = "RateLimit100Requests"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit100Metric"
      sampled_requests_enabled   = true
    }
  }

  # Regra 2: Regra Gerenciada AWS para ameaças comuns da web (OWASP Top 10)
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSCommonRulesMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WizardWAFGlobalMetric"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

# 3. Associação dos Logs do WAF ao CloudWatch
resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.main.arn
}