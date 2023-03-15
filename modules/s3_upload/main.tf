
locals {
  s3_bucket_name = "${var.bucket_name}-${random_id.id.hex}"
}

resource "random_id" "id" {
  byte_length = 5
}

module "s3_upload_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.6.1"

  bucket = local.s3_bucket_name
  acl    = "private"

  versioning = {
    enabled = true
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

resource "aws_s3_bucket_intelligent_tiering_configuration" "tiering_bucket" {
  bucket = module.s3_upload_bucket.s3_bucket_id
  name   = "EntireBucket"

  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = 180
  }
  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 125
  }
}


resource "aws_lambda_function" "lambda_s3_handler" {
  function_name    = "process-s3-new-objects"
  filename         = data.archive_file.lambda_zip_file.output_path
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256
  handler          = "index.handler"
  role             = aws_iam_role.iam_for_lambda.arn
  runtime          = "nodejs14.x"
}

data "archive_file" "lambda_zip_file" {
  type        = "zip"
  source_file = "${path.module}/src/index.js"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  inline_policy {
    name   = "lambda_logs_policy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "AllowLambdaFunctionToCreateLogs",
        "Action": [ 
            "logs:*" 
        ],
        "Effect": "Allow",
        "Resource": [ 
            "arn:aws:logs:*:*:*" 
        ]
    }
  ]
}
EOF
  }
}

resource "aws_lambda_permission" "allow_bucket_invoke_lambda" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_s3_handler.arn
  principal     = "s3.amazonaws.com"
  source_arn    = module.s3_upload_bucket.s3_bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.s3_upload_bucket.s3_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_handler.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket_invoke_lambda]
}