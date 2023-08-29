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

}

resource "aws_batch_job_definition" "simple_batch_job" {
  name = local.name
  type = "container"

  platform_capabilities = [upper("${var.compute_environments}")]

  container_properties = <<CONTAINER_PROPERTIES
  {
    "image": "${var.container_image_url}",
    "command": ["df", "-h"],
    "executionRoleArn": "${aws_iam_role.ecs_task_execution_role.arn}",
    "volumes": [
      {
        "name": "efs",
        "efsVolumeConfiguration": {
          "fileSystemId": "${var.efs_id}"
        }
      }
    ],
    "mountPoints": [
      {
        "containerPath": "/mnt/",
        "readOnly": false,
        "sourceVolume": "efs"
      }
    ],
    "resourceRequirements": [
      {
        "value": "${var.container_vcpu}",
        "type": "VCPU"
      },
      {
        "value": "${var.container_memory}",
        "type": "MEMORY"
      }
    ],
      "fargatePlatformConfiguration": {
      "platformVersion": "1.4.0"
    }
  }
  CONTAINER_PROPERTIES  
}

resource "aws_batch_job_queue" "test-queue" {
  name     = "batch-job-queue"
  state    = "ENABLED"
  priority = 1

  compute_environments = [module.batch.compute_environments.env.arn]
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
