locals {
  name = var.solution_name
}


################################################################################
# Batch Module
################################################################################

module "batch_disabled" {
  source = "terraform-aws-modules/batch/aws"

  create = false
}

module "batch" {
  source = "terraform-aws-modules/batch/aws"

  instance_iam_role_name        = "${local.name}-ecs-instance"
  instance_iam_role_path        = "/batch/"
  instance_iam_role_description = "IAM instance role/profile for AWS Batch ECS instance(s)"
  instance_iam_role_tags = {
    ModuleCreatedRole = "Yes"
  }

  service_iam_role_name        = "${local.name}-batch"
  service_iam_role_path        = "/batch/"
  service_iam_role_description = "IAM service role for AWS Batch"
  service_iam_role_tags = {
    ModuleCreatedRole = "Yes"
  }

  compute_environments = {
    env = {
      name_prefix = "${var.compute_environments}"

      compute_resources = {
        type      = upper("${var.compute_environments}")
        max_vcpus = var.compute_resources_max_vcpus

        security_group_ids = [aws_security_group.batch_security_group.id]
        subnets            = "${var.private_subnets}"
      }
    }
  }

  # Job queues and scheduling policies
  job_queues = {
    low_priority = {
      name     = "LowPriority"
      state    = "ENABLED"
      priority = 1

      tags = {
        JobQueue = "Low priority job queue"
      }
    }

    high_priority = {
      name     = "HighPriority"
      state    = "ENABLED"
      priority = 99

      fair_share_policy = {
        compute_reservation = 1
        share_decay_seconds = 3600

        share_distribution = [{
          share_identifier = "A1*"
          weight_factor    = 0.1
          }, {
          share_identifier = "A2"
          weight_factor    = 0.2
        }]
      }

      tags = {
        JobQueue = "High priority job queue"
      }
    }
  }

  job_definitions = {
    example = {
      name                       = local.name
      propagate_tags             = true
      platform_capabilities      = [upper("${var.compute_environments}")]
      schedulingPriorityOverride = 99

      container_properties = jsonencode({
        command = ["df", "-h"],
        image   = "${var.container_image_url}",
        fargatePlatformConfiguration = {
          platformVersion = "LATEST"
        },
        resourceRequirements = [
          { type = "VCPU", value = tostring(var.container_vcpu) },
          { type = "MEMORY", value = tostring(var.container_memory) }
        ],
        executionRoleArn = aws_iam_role.ecs_task_execution_role.arn
      })

      volumes = {
        name = "efs"

        efs_volume_configuration = {
          file_system_id          = var.efs_id
          root_directory          = "/"
          transit_encryption      = "ENABLED"
          transit_encryption_port = 2999
          authorization_config = {
            iam = "ENABLED"
          }
        }
      }

      attempt_duration_seconds = 120
      retry_strategy = {
        attempts = 3
        evaluate_on_exit = {
          retry_error = {
            action       = "RETRY"
            on_exit_code = 1
          }
          exit_success = {
            action       = "EXIT"
            on_exit_code = 0
          }
        }
      }

      tags = {
        JobDefinition = "Example"
      }
    }
  }
}

################################################################################
# Supporting Resources
################################################################################
resource "aws_security_group" "batch_security_group" {
  name        = "batch_security_group"
  description = "AWS Batch Security Group for batch jobs"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Container to VPC endpoint service"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0", var.base_cidr_block]
    description = "Outbound"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${local.name}-ecs-task-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

data "aws_iam_policy_document" "ecs_task_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
