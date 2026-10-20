output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.s3.id
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.s3.arn
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the bucket"
  value       = aws_s3_bucket.s3.bucket_regional_domain_name
}
