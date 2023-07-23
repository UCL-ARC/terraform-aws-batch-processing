resource "aws_datasync_task" "datasync_task_s3_efs" {
  destination_location_arn = aws_datasync_location_efs.destination.arn
  name                     = "datasync_task"
  source_location_arn      = aws_datasync_location_s3.s3_upload.arn

  options {
    bytes_per_second = -1
  }
}


resource "aws_datasync_location_s3" "s3_upload" {
  s3_bucket_arn = var.upload_s3_arn
  subdirectory  = "/chronostics/"

  s3_config {
    bucket_access_role_arn = aws_iam_role.role_for_datasync_s3.arn
  }
}

resource "aws_efs_access_point" "efs" {
  file_system_id = var.efs_id
}

resource "aws_datasync_location_efs" "destination" {
  # The below example uses aws_efs_mount_target as a reference to ensure a mount target already exists when resource creation occurs.
  # You can accomplish the same behavior with depends_on or an aws_efs_mount_target data source reference.
  efs_file_system_arn = var.efs_arn
  access_point_arn    = aws_efs_access_point.efs.arn

  file_system_access_role_arn = aws_iam_role.role_for_datasync_efs.arn
  in_transit_encryption       = "TLS1_2"
  subdirectory                = "/"

  ec2_config {
    security_group_arns = [
      var.efs_security_group,
      var.batch_security_group
    ]
    subnet_arn = data.aws_subnet.selected.arn
  }
}

data "aws_subnet" "selected" {
  id = var.private_subnets[0]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["datasync.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role_for_datasync_s3" {
  name               = "datasync-s3-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


resource "aws_iam_policy" "datasync_policy_s3" {
  name        = "ARC-datasync-s3"
  description = "Allows datasync to operated with s3"
  policy      = templatefile("${path.module}/templates/datasync_policy.json.tmpl", { s3_arn = var.upload_s3_arn })
}

resource "aws_iam_role_policy_attachment" "datasync-s3-attach" {
  role       = aws_iam_role.role_for_datasync_s3.name
  policy_arn = aws_iam_policy.datasync_policy_s3.arn
}


resource "aws_iam_role" "role_for_datasync_efs" {
  name               = "datasync-efs-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


resource "aws_iam_policy" "datasync_policy_efs" {
  name        = "ARC-datasync-efs"
  description = "Allows datasync to operated with efs"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["datasync:*",
          "ec2:*",
          "elasticfilesystem:*",
          "iam:GetRole",
          "iam:ListRoles",
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups",
          "logs:DescribeResourcePolicies",
          "s3:GetBucketLocation",
          "s3:ListAllMyBuckets",
        "s3:ListBucket"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "datasync-efs-attach" {
  role       = aws_iam_role.role_for_datasync_efs.name
  policy_arn = aws_iam_policy.datasync_policy_efs.arn
}
 