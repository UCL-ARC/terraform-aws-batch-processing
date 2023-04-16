
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
  versioning = {
    enabled = true
  }

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
  handler          = "lambda-invoke-step-function.lambda_handler"
  role             = aws_iam_role.role_for_lambda.arn
  runtime          = "python3.8"

  environment {
    variables = {
      SFN_ARN = var.sfn_state_machine_arn
    }
  }
}

data "archive_file" "lambda_zip_file" {
  type        = "zip"
  source_file = "${path.module}/src/lambda-invoke-step-function.py"
  output_path = "${path.module}/lambda.zip"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role_for_lambda" {
  name               = "lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_sfn_policy" {
  name = "lambda_sfn_execution"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["states:StartExecution"]
        Effect   = "Allow"
        Resource = "${var.sfn_state_machine_arn}"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "sfn-attach" {
   role       = aws_iam_role.role_for_lambda.name
   policy_arn = aws_iam_policy.lambda_sfn_policy.arn
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
