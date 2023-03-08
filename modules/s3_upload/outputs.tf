# ARN of the s3 bucket.
output "s3_arn" {
  value = module.s3_upload_bucket.s3_bucket_arn
}
