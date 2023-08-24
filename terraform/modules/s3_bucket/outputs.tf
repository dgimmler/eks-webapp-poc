output "bucket_name" {
  description = "The name of the created S3 Bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "The ARN of the created S3 Bucket"
  value       = aws_s3_bucket.main.arn
}
