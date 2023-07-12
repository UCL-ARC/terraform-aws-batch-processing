locals {
  s3_bucket_name = "${var.bucket_name}-${random_id.id.hex}"
}

resource "random_id" "id" {
  byte_length = 5
}

module "s3_reports_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.s3_bucket_name
  versioning = {
    enabled = true
  }

}