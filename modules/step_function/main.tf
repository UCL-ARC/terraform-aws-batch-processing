locals {
  account_id     = data.aws_caller_identity.current.account_id
  job_definition = var.batch_job_definitions["example"]
  job_queue      = var.batch_job_queues["high_priority"]
}

data "aws_caller_identity" "current" {}


module "step_function" {
  source = "terraform-aws-modules/step-functions/aws"

  name       = "sfn-batch-example"
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
          "JobDefinition": "${local.job_definition.arn}",
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


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role_for_sfn" {
  name               = "sfn-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "sfn_batch_policy" {
  name = "sfn_batch_execution"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["batch:SubmitJob",
          "batch:DescribeJobs",
        "batch:TerminateJob"]
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

resource "aws_iam_role_policy_attachment" "batch-attach" {
  role       = aws_iam_role.role_for_sfn.name
  policy_arn = aws_iam_policy.sfn_batch_policy.arn
}
