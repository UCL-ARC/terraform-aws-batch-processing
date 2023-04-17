locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}


module "step_function" {
  source = "terraform-aws-modules/step-functions/aws"

  name       = "my-step-function"
  definition = <<EOF
  {
    "Comment": "Example Task",
    "StartAt": "BATCH_JOB",
    "States": {
      "BATCH_JOB": {
        "Type": "Task",
        "End": true,
        "Resource": "arn:aws:states:${var.region}:${local.account_id}:batch:submitJob.sync",
        "Parameters": {
          "JobDefinition": "test-processing",
          "JobName": "ProcessingBatchJob",
          "JobQueue": "HighPriority"
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
      identifiers = ["states.${var.region}.amazonaws.com"]
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
        Action   = ["batch:SubmitJob"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "batch-attach" {
  role       = aws_iam_role.role_for_sfn.name
  policy_arn = aws_iam_policy.sfn_batch_policy.arn
}
