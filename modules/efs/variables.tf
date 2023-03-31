variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "The region to deploy into."
}

variable "solution_name" {
  type        = string
  description = "Overall name for the solution"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnets" {
  type        = list(string)
  description = "VPC private subnets' IDs list"
}

variable "base_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "efs_transition_to_ia_period" {
  type        = string
  default     = "AFTER_7_DAYS"
  description = "Lifecycle policy transition period to IA"
}

variable "efs_throughput_in_mibps" {
  type        = number
  default     = 1
  description = "EFS provisioned throughput in mibps"
}