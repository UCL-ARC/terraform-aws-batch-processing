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
| <a name="module_appstream"></a> [appstream](#module\_appstream) | ./modules/appstream | n/a |
| <a name="module_batch"></a> [batch](#module\_batch) | ./modules/batch | n/a |
| <a name="module_efs"></a> [efs](#module\_efs) | ./modules/efs | n/a |
| <a name="module_s3_upload"></a> [s3\_upload](#module\_s3\_upload) | ./modules/s3_upload | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_as2_desired_instance_num"></a> [as2\_desired\_instance\_num](#input\_as2\_desired\_instance\_num) | Desired number of AS2 instances | `number` | `1` | no |
| <a name="input_as2_fleet_description"></a> [as2\_fleet\_description](#input\_as2\_fleet\_description) | Fleet description | `string` | `"ARC batch process fleet"` | no |
| <a name="input_as2_fleet_display_name"></a> [as2\_fleet\_display\_name](#input\_as2\_fleet\_display\_name) | Fleet diplay name | `string` | `"ARC batch process fleet"` | no |
| <a name="input_as2_fleet_name"></a> [as2\_fleet\_name](#input\_as2\_fleet\_name) | Fleet name | `string` | `"ARC-batch-fleet"` | no |
| <a name="input_as2_image_name"></a> [as2\_image\_name](#input\_as2\_image\_name) | AS2 image to deploy | `string` | n/a | yes |
| <a name="input_as2_instance_type"></a> [as2\_instance\_type](#input\_as2\_instance\_type) | AS2 instance type | `string` | `"stream.standard.medium"` | no |
| <a name="input_as2_stack_description"></a> [as2\_stack\_description](#input\_as2\_stack\_description) | Stack description | `string` | `"ARC batch process stack"` | no |
| <a name="input_as2_stack_display_name"></a> [as2\_stack\_display\_name](#input\_as2\_stack\_display\_name) | Stack diplay name | `string` | `"ARC batch process stack"` | no |
| <a name="input_as2_stack_name"></a> [as2\_stack\_name](#input\_as2\_stack\_name) | Stack name | `string` | `"ARC-batch-stack"` | no |
| <a name="input_compute_environments"></a> [compute\_environments](#input\_compute\_environments) | Compute environments | `string` | `"fargate"` | no |
| <a name="input_compute_resources_max_vcpus"></a> [compute\_resources\_max\_vcpus](#input\_compute\_resources\_max\_vcpus) | Max VCPUs resources | `number` | `1` | no |
| <a name="input_container_image_url"></a> [container\_image\_url](#input\_container\_image\_url) | Container image URL | `string` | `"public.ecr.aws/docker/library/busybox:latest"` | no |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | Containter Memory resources | `number` | `2048` | no |
| <a name="input_container_vcpu"></a> [container\_vcpu](#input\_container\_vcpu) | Containter VCPUs resources | `number` | `1` | no |
| <a name="input_efs_throughput_in_mibps"></a> [efs\_throughput\_in\_mibps](#input\_efs\_throughput\_in\_mibps) | EFS provisioned throughput in mibps | `number` | `1` | no |
| <a name="input_efs_transition_to_ia_period"></a> [efs\_transition\_to\_ia\_period](#input\_efs\_transition\_to\_ia\_period) | Lifecycle policy transition period to IA | `string` | `"AFTER_7_DAYS"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to deploy into. | `string` | `"eu-west-2"` | no |
| <a name="input_solution_name"></a> [solution\_name](#input\_solution\_name) | Overall name for the solution | `string` | `"arc-batch"` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block for the VPC | `string` | `"10.0.0.0/25"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->