locals {
  definition_template = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using Pass states",
  "StartAt": "Hello",
  "States": {
    "Hello": {
      "Type": "Pass",
      "Result": "Hello",
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