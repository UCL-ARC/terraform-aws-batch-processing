
locals  {
  s3_bucket_name = "${var.bucket_name}-${random_id.id.hex}"
}

resource "random_id" "id" {
  byte_length = 5
}

resource "aws_s3_bucket" "s3_upload_bucket"{
  bucket        = local.s3_bucket_name
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "tiering_bucket"{
  bucket = aws_s3_bucket.s3_upload_bucket.id
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