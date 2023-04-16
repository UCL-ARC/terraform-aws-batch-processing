locals {
  definition_template = <<EOF
{
  "Comment": "Datasync Task",
  "StartAt": "Sync",
  "States": {
    "Sync": {
      "Type": "Task",
      "End" : true,
      "Resource" : "${var.datasync_task_arn}",
      "Next": "World"
    },
    "World": {
      "Type": "Pass",
      "Result": "World",
      "End": true
    }
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