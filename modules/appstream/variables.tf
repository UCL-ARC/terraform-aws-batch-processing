# AppStream vars
variable "desired_instance_num" {
  type        = number
  description = "Desired number of AS2 instances"
  default     = 1
}

variable "fleet_name" {
  type        = string
  description = "Fleet name"
  default     = "ARC-batch-fleet"
}

variable "fleet_description" {
  type        = string
  description = "Fleet description"
  default     = "ARC batch process fleet"
}

variable "fleet_display_name" {
  type        = string
  description = "Fleet diplay name"
  default     = "ARC batch process fleet"
}

#variable "fleet_sg_ids" {
#  type        = list(string)
#  description = "Security group IDs for fleet"
#}

variable "fleet_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for fleet"
}

variable "image_name" {
  type        = string
  description = "AS2 image to deploy"
}

variable "instance_type" {
  type        = string
  description = "AS2 instance type"
  default     = "stream.standard.medium"
}

variable "s3_arn" {
  description = "ARN of the s3 bucket to read from."
  type        = string
}

variable "stack_name" {
  type        = string
  description = "Stack name"
  default     = "ARC-batch-stack"
}

variable "stack_description" {
  type        = string
  description = "Stack description"
  default     = "ARC batch process stack"
}

variable "stack_display_name" {
  type        = string
  description = "Stack diplay name"
  default     = "ARC batch process stack"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}