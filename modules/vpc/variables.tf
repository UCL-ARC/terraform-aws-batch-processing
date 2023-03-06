
variable "base_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "The region to deploy into."
}

variable "solution_name" {
  type        = string
  description = "Overall name for the solution"
}