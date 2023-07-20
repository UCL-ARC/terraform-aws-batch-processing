locals {
  account_id     = data.aws_caller_identity.current.account_id
  job_queue      = var.batch_job_queues["high_priority"]
}

data "aws_caller_identity" "current" {}


module "step_function" {
  source = "terraform-aws-modules/step-functions/aws"

  name       = "sfn-batch"
  definition = <<EOF
  {
    "Comment": "Example State Machine",
    "StartAt": "BATCH_JOB",
    "States": {
      "BATCH_JOB": {
        "Type": "Task",
        "End": true,
        "Resource": "arn:aws:states:::batch:submitJob.sync",
        "Parameters": {
          "JobDefinition": "${var.batch_task_arn}",
          "JobName": "Test Batch",
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
  name = "sfn-batch"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "states.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "sfn_batch_policy" {
  name = "sfn-batch"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["batch:SubmitJob",
          "batch:DescribeJobs",
        "batch:TerminateJob"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the job role
resource "aws_iam_role_policy_attachment" "job_policy_attachment" {
  role       = aws_iam_role.role_for_sfn.name
  policy_arn = aws_iam_policy.sfn_batch_policy.arn
}