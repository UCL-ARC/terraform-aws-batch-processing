resource "aws_datasync_task" "datasync_task" {
  destination_location_arn = aws_datasync_location_efs.destination.arn
  name                     = "datasync_task"
  source_location_arn      = aws_datasync_location_s3.source.arn

  options {
    bytes_per_second = -1
  }
}


resource "aws_datasync_location_s3" "source" {
  s3_bucket_arn = var.s3_arn
  subdirectory  = "/example/"

  s3_config {
    bucket_access_role_arn = aws_iam_role.role_for_datasync.arn
  }
}

resource "aws_datasync_location_efs" "destination" {
  # The below example uses aws_efs_mount_target as a reference to ensure a mount target already exists when resource creation occurs.
  # You can accomplish the same behavior with depends_on or an aws_efs_mount_target data source reference.
  efs_file_system_arn = var.efs_arn

  ec2_config {
    security_group_arns = [var.security_group_arns]
    subnet_arn          = aws_subnet.main.arn
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

resource "aws_iam_role" "role_for_datasync" {
  name               = "datasync-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


resource "aws_iam_policy" "datasync_policy" {
  name        = "ARC-datasync"
  description = "Allows datasync to operated between s3 and efs"
  policy      = templatefile("${path.module}/templates/datasync_policy.json.tmpl", { s3_arn = var.s3_arn })
}

resource "aws_iam_role_policy_attachment" "datasync-s3-attach" {
  role       = aws_iam_role.role_for_datasync.name
  policy_arn = aws_iam_policy.datasync_policy.arn
}
 