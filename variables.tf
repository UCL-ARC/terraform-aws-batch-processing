variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "The region to deploy into."
}

variable "solution_name" {
  type        = string
  default     = "arc-batch"
  description = "Overall name for the solution"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/25"
  description = "The CIDR block for the VPC"
}

variable "efs_transition_to_ia_period" {
  type        = string
  default     = "AFTER_7_DAYS"
  description = "Lifecycle policy transition period to IA"
}
