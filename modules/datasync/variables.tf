variable "private_subnets" {
  type        = list(string)
  description = "VPC private subnets' IDs list"
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

variable "efs_access_points" {
  type        = string
  description = "EFS access points"
}

variable "security_group_arns" {
  type        = list(string)
  description = "Security group arns"
}
