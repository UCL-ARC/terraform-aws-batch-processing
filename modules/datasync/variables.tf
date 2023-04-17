# ARN of the s3 bucket.
variable "s3_arn" {
  type        = string
  description = "ARN of the s3 bucket"
}

variable "efs_arn" {
  type        = string
  description = "The ID of the EFS file system to copy data to"
}

variable "security_group_arns" {
  type        = string
  description = "Security group arns"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "base_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
}