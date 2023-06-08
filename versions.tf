# Enforce minimum Terraform and AWS provider version numbers.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }

  required_version = ">= 1.3.9"
}