terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.sa_east_1]
    }
  }
}

# ----------------------------------------------------
# 1. BUCKET PRIMÁRIO (SÃO PAULO / sa-east-1)
# ----------------------------------------------------
resource "aws_s3_bucket" "primary" {
  provider      = aws.sa_east_1
  bucket        = "${var.bucket_prefix}-sa-east-1-primary"
  force_destroy = true

  tags = merge(var.tags, {
    Name = "${var.bucket_prefix}-sa-east-1-primary"
    Role = "Primary Origin sa-east-1"
  })
}

# Bloqueio de Acesso Público no Bucket Primário
resource "aws_s3_bucket_public_access_block" "primary_block" {
  provider = aws.sa_east_1
  bucket   = aws_s3_bucket.primary.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload do index.html para o Primário
resource "aws_s3_object" "primary_index" {
  provider     = aws.sa_east_1
  bucket       = aws_s3_bucket.primary.id
  key          = "index.html"
  source       = var.html_filepath
  content_type = "text/html"
  etag         = filemd5(var.html_filepath)

  depends_on = [aws_s3_bucket.primary]
}

# ----------------------------------------------------
# 2. BUCKET DE CONTINGÊNCIA / FAILOVER (VIRGÍNIA / us-east-1)
# ----------------------------------------------------
resource "aws_s3_bucket" "failover" {
  bucket        = "${var.bucket_prefix}-us-east-1-failover"
  force_destroy = true

  tags = merge(var.tags, {
    Name = "${var.bucket_prefix}-us-east-1-failover"
    Role = "Failover Origin us-east-1"
  })
}

# Bloqueio de Acesso Público no Bucket de Failover
resource "aws_s3_bucket_public_access_block" "failover_block" {
  bucket = aws_s3_bucket.failover.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload do index.html para o Failover
resource "aws_s3_object" "failover_index" {
  bucket       = aws_s3_bucket.failover.id
  key          = "index.html"
  source       = var.html_filepath
  content_type = "text/html"
  etag         = filemd5(var.html_filepath)

  depends_on = [aws_s3_bucket.failover]
}