# ----------------------------------------------------
# 1. BUCKET PRIMÁRIO
# ----------------------------------------------------
resource "aws_s3_bucket" "primary" {
  bucket        = "${var.bucket_prefix}-primary"
  force_destroy = true

  tags = merge(var.tags, {
    Name = "${var.bucket_prefix}-primary"
    Role = "Primary Origin"
  })
}

# Bloqueio de Acesso Público no Bucket Primário
resource "aws_s3_bucket_public_access_block" "primary_block" {
  bucket = aws_s3_bucket.primary.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload do index.html para o Primário
resource "aws_s3_object" "primary_index" {
  bucket       = aws_s3_bucket.primary.id
  key          = "index.html"
  source       = var.html_filepath
  content_type = "text/html"
  etag         = filemd5(var.html_filepath)

  depends_on = [aws_s3_bucket.primary]
}

# ----------------------------------------------------
# 2. BUCKET DE CONTINGÊNCIA / FAILOVER
# ----------------------------------------------------
resource "aws_s3_bucket" "failover" {
  bucket        = "${var.bucket_prefix}-failover"
  force_destroy = true

  tags = merge(var.tags, {
    Name = "${var.bucket_prefix}-failover"
    Role = "Failover Origin"
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