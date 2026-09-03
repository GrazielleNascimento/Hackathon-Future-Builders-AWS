# 1. Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "wizard-s3-oac"
  description                       = "OAC para buckets S3 Wizard"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 2. Distribuição CloudFront com Origin Group (Failover)
resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  web_acl_id          = var.web_acl_id

  # Origem 1: Bucket Primário
  origin {
    domain_name              = var.primary_bucket_regional_domain_name
    origin_id                = "PrimaryS3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # Origem 2: Bucket Failover
  origin {
    domain_name              = var.failover_bucket_regional_domain_name
    origin_id                = "FailoverS3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # Grupo de Origem com Failover Automático
  origin_group {
    origin_id = "S3OriginGroup"

    failover_criteria {
      status_codes = [403, 404, 500, 502, 503, 504]
    }

    member {
      origin_id = "PrimaryS3Origin"
    }

    member {
      origin_id = "FailoverS3Origin"
    }
  }

  # Comportamento Padrão de Cache (Apontando para o Grupo de Failover)
  default_cache_behavior {
    target_origin_id       = "S3OriginGroup"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    # Managed-CachingOptimized (ID padrão gerenciado da AWS)
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = var.tags
}