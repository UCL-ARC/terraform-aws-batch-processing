locals {
  account_id = data.aws_caller_identity.current.account_id
  job_queue  = var.batch_job_queues["high_priority"]
}

data "aws_caller_identity" "current" {}


module "step_function" {
  source = "terraform-aws-modules/step-functions/aws"

  name       = "sfn-datasync-batch"
  definition = <<EOF
  {
  "Comment": "Example State Machine",
  "StartAt": "Data_Sync_s3_efs",
  "States": {
    "Data_Sync_s3_efs": {
      "Type": "Task",
      "Next": "BATCH_JOB",
      "Parameters": {
        "TaskArn": "${var.datasync_task_s3_efs}"
      },
      "Resource": "arn:aws:states:::aws-sdk:datasync:startTaskExecution"
    },
    "BATCH_JOB": {
      "Type": "Task",
      "Resource": "arn:aws:states:::batch:submitJob.sync",
      "Parameters": {
        "JobDefinition": "${var.batch_task_arn}",
        "JobQueue": "${local.job_queue.arn}",
        "JobName": "simple",
        "ShareIdentifier": "test"
      },
      "Next": "Data_Sync_efs_s3"
    },
    "Data_Sync_efs_s3": {
      "Type": "Task",
      "End": true,
      "Parameters": {
        "TaskArn": "${var.datasync_task_efs_s3}"
      },
      "Resource": "arn:aws:states:::aws-sdk:datasync:startTaskExecution"
    }
  }
}
  EOF
  service_integrations = {
    batch_Sync = {
      events = true
    }
  }

  attach_policy = true
  policy = aws_iam_policy.sfn_batch_policy.arn

  type = "STANDARD"

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
