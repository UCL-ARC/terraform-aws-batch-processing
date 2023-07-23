variable "private_subnets" {
  type        = list(string)
  description = "VPC private subnets' IDs list"
}

# ARN of the s3 bucket.
variable "upload_s3_arn" {
  type        = string
  description = "ARN of the upload s3 bucket"
}

# ARN of the s3 bucket.
variable "reports_s3_arn" {
  type        = string
  description = "ARN of the reports s3 bucket"
}

variable "efs_arn" {
  type        = string
  description = "The ID of the EFS file system to copy data to"
}

variable "security_group_arns" {
  type        = list(string)
  description = "Security group arns"
}

variable "efs_access_points_arn" {
  type        = list(string)
  description = "Security group arns"
}