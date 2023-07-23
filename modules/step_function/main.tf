locals {
  account_id = data.aws_caller_identity.current.account_id
  job_queue  = var.batch_job_queues["high_priority"]
}

data "aws_caller_identity" "current" {}


module "step_function" {
  source = "terraform-aws-modules/step-functions/aws"

  name       = "sfn-batch-test"
  definition = <<EOF
  {
  "Comment": "Example State Machine",
  "StartAt": "StartTaskExecution",
  "States": {
    "StartTaskExecution": {
      "Type": "Task",
      "Next": "BATCH_JOB",
      "Parameters": {
        "TaskArn": "${var.datasync_task_s3_efs}"
      },
      "Resource": "arn:aws:states:::datasync:startTaskExecution"
    },
    "BATCH_JOB": {
      "Type": "Task",
      "End": true,
      "Resource": "arn:aws:states:::batch:submitJob.sync",
      "Parameters": {
        "JobDefinition": "${var.batch_task_arn}",
        "JobQueue": "${local.job_queue.arn}",
        "JobName": "example",
        "ShareIdentifier": "test"
      }
    }
  }
}
  EOF

  service_integrations = {
    batch_Sync = {
      events = true
    }
  }

  type = "STANDARD"

}


resource "aws_iam_role" "role_for_sfn" {
  name = "sfn-batch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      },
    ]
  })
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

resource "aws_iam_policy" "sfn_batch_policy" {
  name = "sfn-batch-policy"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["batch:SubmitJob",
          "batch:DescribeJobs",
          "batch:TerminateJob",
          "datasync:*",
        "ec2:*"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = ["events:PutTargets",
          "events:PutRule",
        "events:DescribeRule"]
        Effect   = "Allow"
        Resource = "arn:aws:events:${var.region}:${local.account_id}:rule/StepFunctionsGetEventsForBatchJobsRule"
      }
    ]
  })
}

# Attach the policy to the job role
resource "aws_iam_role_policy_attachment" "job_policy_attachment" {
  role       = aws_iam_role.role_for_sfn.name
  policy_arn = aws_iam_policy.sfn_batch_policy.arn
}
