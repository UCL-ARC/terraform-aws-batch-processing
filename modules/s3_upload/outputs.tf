# ARN of the s3 bucket.
output "s3_arn" {
  value = module.s3_upload_bucket.s3_bucket_arn
}

# Outputting lambda source code hash
output "lambda_source_code_hash" {
  value = aws_lambda_function.lambda_s3_handler.source_code_hash
}
