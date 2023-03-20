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
  source      = "./modules/s3_upload"
  region      = var.region
  bucket_name = "${var.solution_name}-upload"
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
