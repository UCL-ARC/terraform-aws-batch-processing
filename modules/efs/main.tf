locals {
  name = var.solution_name
}

data "aws_caller_identity" "current" {}

module "efs" {
  source = "terraform-aws-modules/efs/aws"

  # File system
  name           = "efs"
  creation_token = "efs-token"
  encrypted      = true
  kms_key_arn    = module.kms.key_arn

  performance_mode                = "generalPurpose"
  throughput_mode                 = "provisioned"
  provisioned_throughput_in_mibps = var.efs_throughput_in_mibps

  lifecycle_policy = {
    transition_to_ia = var.efs_transition_to_ia_period
  }

  # Access point(s)
  access_points = {
    posix_example = {
      name = "posix-example"
      posix_user = {
        gid            = 1001
        uid            = 1001
        secondary_gids = [1002]
      }

      tags = {
        Additionl = "yes"
      }
    }
    root_example = {
      root_directory = {
        path = "/"
        creation_info = {
          owner_gid   = 1001
          owner_uid   = 1001
          permissions = "755"
        }
      }
    }
  }

  # Backup policy
  enable_backup_policy = true

  # Replication configuration
  create_replication_configuration = true
  replication_configuration_destination = {
    region = "${var.region}"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "efs_security_group" {
  name        = "efs_security_group"
  description = "Allow NFS traffic."
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.batch_security_group]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.base_cidr_block]
    description = "No Outbound Restrictions"
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count          = length(var.private_subnets)
  file_system_id = module.efs.id
  subnet_id      = element(tolist(var.private_subnets), count.index)
  security_groups = [
    aws_security_group.efs_security_group.id,
    var.batch_security_group
  ]
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.0"

  aliases               = ["efs/${local.name}"]
  description           = "EFS customer managed key"
  enable_default_policy = true

  # For example use only
  deletion_window_in_days = 7
}

data "aws_iam_policy_document" "efs-policy" {
  statement {
    sid    = "1"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
    ]

    resources = [module.efs.arn]
  }
}

resource "aws_efs_file_system_policy" "policy" {
  file_system_id = module.efs.id
  policy         = data.aws_iam_policy_document.policy.json
}
