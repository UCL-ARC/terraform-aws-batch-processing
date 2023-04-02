resource "aws_security_group" "appstream" {
  name_prefix = "appstream"
  description = "Allow S3 egress from AppStream"
  vpc_id      = var.vpc_id
}

data "aws_region" "current" {}

data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

resource "aws_security_group_rule" "s3_gateway_egress" {
  type              = "egress"
  description       = "S3 gateway egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.appstream.id
  prefix_list_ids   = [data.aws_prefix_list.s3.id]
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["appstream.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "s3_policy" {
  name        = "ARC-AS2-ReadOnly-S3"
  description = "Allows reading of s3 upload bucket"
  policy      = templatefile("${path.module}/templates/s3-read-only.json.tmpl", { s3_arn = var.s3_arn })
}

resource "aws_iam_role" "as2_role" {
  name               = "ARC-AS2-S3-Role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.s3_policy.arn
  ]
}