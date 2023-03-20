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
  provisioned_throughput_in_mibps = 256

  lifecycle_policy = {
    transition_to_ia = var.efs_transition_to_ia_period
  }

  # File system policy
  attach_policy                      = true
  bypass_policy_lockout_safety_check = false
  policy_statements = [
    {
      sid     = "${local.name}-efs"
      effect  = ["Allow"]
      actions = ["elasticfilesystem:*"]
      principals = [
        {
          type        = "AWS"
          identifiers = ["*"]
        }
      ]
      condition = [
        {
          test     = "Bool"
          variable = "aws:SecureTransport"
          values   = ["true"]
        }
      ]
    }
  ]

  # Mount targets / security group
  mount_targets = {
    "${var.region}" = {
      subnet_id = element(var.private_subnets, 0)
    }
    "${var.region}" = {
      subnet_id = element(var.private_subnets, 1)
    }
  }
  security_group_description = "EFS security group"
  security_group_vpc_id      = var.vpc_id
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = [var.base_cidr_block]
    }
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
        path = "/example"
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

# data "aws_iam_policy_document" "policy" {
#   statement {
#     sid    = "ExampleStatement01"
#     effect = "Allow"

#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }

#     actions = [
#       "elasticfilesystem:ClientMount",
#       "elasticfilesystem:ClientWrite",
#     ]

#     resources = [module.efs.arn]

#     condition {
#       test     = "Bool"
#       variable = "aws:SecureTransport"
#       values   = ["true"]
#     }
#   }
# }

# resource "aws_efs_mount_target" "alpha" {
#   file_system_id = module.efs.id
#   subnet_id      = element(var.private_subnets, 0)
# }

# resource "aws_vpc" "foo" {
#   cidr_block = "10.0.0.0/16"
# }

# resource "aws_subnet" "alpha" {
#   vpc_id            = aws_vpc.foo.id
#   availability_zone = "us-west-2a"
#   cidr_block        = "10.0.1.0/24"
# }

# resource "aws_efs_file_system_policy" "policy" {
#   file_system_id                     = aws_efs_file_system.fs.id
#   bypass_policy_lockout_safety_check = true
#   policy                             = data.aws_iam_policy_document.policy.json
# }

# resource "aws_efs_mount_target" "alpha" {
#   file_system_id = aws_efs_file_system.foo.id
#   subnet_id      = aws_subnet.alpha.id
# }

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.0"

  aliases               = ["efs/${local.name}"]
  description           = "EFS customer managed key"
  enable_default_policy = true

  # For example use only
  deletion_window_in_days = 7
}
