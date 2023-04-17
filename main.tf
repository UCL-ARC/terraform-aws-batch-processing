# Set primary region.
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Terraform = "true"
    }
  }

}

module "vpc" {
  source          = "./modules/vpc"
  solution_name   = var.solution_name
  region          = var.region
  base_cidr_block = var.vpc_cidr_block
}

module "s3_upload" {
  source                = "./modules/s3_upload"
  region                = var.region
  bucket_name           = "${var.solution_name}-upload"
  sfn_state_machine_arn = module.step_function.sfn_state_machine_arn
}

module "efs" {
  source                      = "./modules/efs"
  region                      = var.region
  solution_name               = var.solution_name
  vpc_id                      = module.vpc.vpc_id
  private_subnets             = module.vpc.private_subnets
  base_cidr_block             = var.vpc_cidr_block
  efs_transition_to_ia_period = var.efs_transition_to_ia_period
  efs_throughput_in_mibps     = var.efs_throughput_in_mibps
}

module "batch" {
  source                      = "./modules/batch"
  solution_name               = var.solution_name
  vpc_id                      = module.vpc.vpc_id
  private_subnets             = module.vpc.private_subnets
  compute_environments        = var.compute_environments
  compute_resources_max_vcpus = var.compute_resources_max_vcpus
  container_image_url         = var.container_image_url
  container_vcpu              = var.container_vcpu
  container_memory            = var.container_memory
  efs_id                      = module.efs.efs_id
}

module "step_function" {
  source            = "./modules/step_function"
  datasync_task_arn = module.datasync.datasync_task_arn
}

module "appstream" {
  source               = "./modules/appstream"
  desired_instance_num = var.as2_desired_instance_num
  fleet_name           = var.as2_fleet_name
  fleet_description    = var.as2_fleet_description
  fleet_display_name   = var.as2_fleet_display_name
  #fleet_sg_ids         = var.as2_fleet_sg_ids
  vpc_id             = module.vpc.vpc_id
  fleet_subnet_ids   = module.vpc.private_subnets
  image_name         = var.as2_image_name
  instance_type      = var.as2_instance_type
  stack_name         = var.as2_stack_name
  stack_description  = var.as2_stack_description
  stack_display_name = var.as2_stack_display_name

  s3_arn = module.s3_upload.s3_arn
}

module "datasync" {
  source              = "./modules/datasync"
  efs_dns_name     = module.efs.dns_name
  s3_arn              = module.s3_upload.s3_arn
  efs_arn             = module.efs.efs_arn
  security_group_arns = module.efs.security_group_arn
}

module "s3_reports" {
  source      = "./modules/s3_reports"
  region      = var.region
  bucket_name = "${var.solution_name}-reports"
}
