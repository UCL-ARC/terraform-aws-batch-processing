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
      "Next": "Poll_DataSyncS3toEFS",
      "Parameters": {
        "TaskArn": "${var.datasync_task_s3_efs}"
      },
      "Resource": "arn:aws:states:::aws-sdk:datasync:startTaskExecution"
    },
    "Poll_DataSyncS3toEFS": {
      "Type": "Task",
      "Next": "Check_DataSyncS3toEFS",
      "Parameters": {
        "TaskExecutionArn.$": "$.TaskExecutionArn"
      },
      "Resource": "arn:aws:states:::aws-sdk:datasync:describeTaskExecution"
    },
    "Check_DataSyncS3toEFS": {
      "Type": "Choice",
      "Choices": [
        {
          "Not": {
            "Variable": "$.Status",
            "StringEquals": "SUCCESS"
          },
          "Next": "Wait"
        },
        {
          "Variable": "$.Status",
          "StringEquals": "SUCCESS",
          "Next": "BATCH_JOB"
        },
        {
          "Variable": "$.Status",
          "StringEquals": "ERROR",
          "Next": "HandleError"
        }
      ],
      "Default": "HandleError"
    },
    "Wait": {
      "Type": "Wait",
      "Seconds": 300,
      "Next": "Poll_DataSyncS3toEFS"
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
      "Next": "Poll_DataSyncEFStoS3", 
      "Parameters": {
        "TaskArn": "${var.datasync_task_efs_s3}"
      },
      "Resource": "arn:aws:states:::aws-sdk:datasync:startTaskExecution"
    },
   "Poll_DataSyncEFStoS3": {
      "Type": "Task",
      "Next": "Check_DataSyncEFStoS3",
      "Parameters": {
        "TaskExecutionArn.$": "$.TaskExecutionArn"
      },
      "Resource": "arn:aws:states:::aws-sdk:datasync:describeTaskExecution"
    },
    "Check_DataSyncEFStoS3": {
      "Type": "Choice",
      "Choices": [
        {
          "Not": {
            "Variable": "$.Status",
            "StringEquals": "SUCCESS"
          },
          "Next": "WaitEFStoS3"
        },
        {
          "Variable": "$.Status",
          "StringEquals": "SUCCESS",
          "Next": "EndState"
        },
        {
          "Variable": "$.Status",
          "StringEquals": "ERROR",
          "Next": "HandleError"
        }
      ],
      "Default": "HandleError"
    },
    "WaitEFStoS3": {
      "Type": "Wait",
      "Seconds": 300,
      "Next": "Poll_DataSyncEFStoS3"
    },
    "HandleError": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "End": true,
      "Parameters": {
        "Message": {
          "Message": "An error occurred during DataSync."
        },
        "TopicArn.$": "$.DataSync-Topic"
      }
    },
    "EndState": {
    "Type": "Pass",
    "Result": "The DataSync process has completed successfully.",
    "End": true
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
  policy        = aws_iam_policy.sfn_batch_policy.arn

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
