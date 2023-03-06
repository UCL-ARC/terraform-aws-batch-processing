# Set primary region.
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Terraform   = "true"
    }
  }

}

module "vpc" {
  source          = "./modules/vpc"
  solution_name   = "${var.solution_name}"
  region          = var.region
}