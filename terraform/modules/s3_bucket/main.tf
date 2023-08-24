resource "aws_s3_bucket" "main" {
  provider = aws

  bucket = local.bucket_name

  force_destroy = true # no need to keep artifacts

  tags = var.tags
}


resource "aws_s3_bucket_public_access_block" "main" {
  provider = aws

  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "main" {
  provider = aws

  bucket = aws_s3_bucket.main.id
  policy = templatefile("${path.module}/policy.json", {
    bucket_name = local.bucket_name
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  provider = aws

  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
