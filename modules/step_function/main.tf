locals {
  definition_template = <<EOF
{
  "StartAt": "BATCH_JOB",
  "States": {
    "BATCH_JOB": {
      "Type": "Task",
      "End" : true,
      "Resource" : "${var.batch_task_arn}"
      },
    },
  }
}
EOF
}


module "step_function" {
  source = "terraform-aws-modules/step-functions/aws"

  name       = "my-step-function"
  definition = local.definition_template


  service_integrations = {
    batch_Sync = {
      events = true
    }
  }

  type = "STANDARD"

}