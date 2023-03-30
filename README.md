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
| <a name="module_batch"></a> [batch](#module\_batch) | ./modules/batch | n/a |
| <a name="module_efs"></a> [efs](#module\_efs) | ./modules/efs | n/a |
| <a name="module_s3_upload"></a> [s3\_upload](#module\_s3\_upload) | ./modules/s3_upload | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
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