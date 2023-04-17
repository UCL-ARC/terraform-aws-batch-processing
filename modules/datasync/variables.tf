variable "efs_mount_target" {
  type        = map
  description = "EFS Mount Targets"
}

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