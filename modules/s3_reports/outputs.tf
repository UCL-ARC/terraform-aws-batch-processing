# ARN of the s3 bucket.
output "s3_reports_arn" {
  value = module.s3_reports_bucket.s3_bucket_arn
}
