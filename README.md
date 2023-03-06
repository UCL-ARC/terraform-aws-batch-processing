# terraform-aws-batch-processing
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.45.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | The region to deploy into. | `string` | `"eu-west-2"` | no |
| <a name="input_solution_name"></a> [solution\_name](#input\_solution\_name) | Overall name for the solution | `string` | `"arc-batch"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->