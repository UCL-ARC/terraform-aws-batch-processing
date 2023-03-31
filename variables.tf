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

variable "efs_throughput_in_mibps" {
  type        = number
  default     = 1
  description = "EFS provisioned throughput in mibps"
}

variable "compute_environments" {
  type        = string
  description = "Compute environments"
  default     = "fargate"
}

variable "compute_resources_max_vcpus" {
  type        = number
  description = "Max VCPUs resources"
  default     = 1
}
variable "container_image_url" {
  type        = string
  description = "Container image URL"
  default     = "public.ecr.aws/docker/library/busybox:latest"
}
variable "container_vcpu" {
  type        = number
  description = "Containter VCPUs resources"
  default     = 1
}
variable "container_memory" {
  type        = number
  description = "Containter Memory resources"
  default     = 2048
}

# AppStream vars
variable "as2_desired_instance_num" {
  type        = number
  description = "Desired number of AS2 instances"
  default     = 1
}

variable "as2_fleet_name" {
  type        = string
  description = "Fleet name"
  default     = "ARC-batch-fleet"
}

variable "as2_fleet_description" {
  type        = string
  description = "Fleet description"
  default     = "ARC batch process fleet"
}

variable "as2_fleet_display_name" {
  type        = string
  description = "Fleet diplay name"
  default     = "ARC batch process fleet"
}

#variable "as2_fleet_sg_ids" {
#  type        = list(string)
#  description = "Security group IDs for fleet"
#}

variable "as2_fleet_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for fleet"
}

variable "as2_image_name" {
  type        = string
  description = "AS2 image to deploy"
}

variable "as2_instance_type" {
  type        = string
  description = "AS2 instance type"
  default     = "stream.standard.medium"
}

variable "as2_stack_name" {
  type        = string
  description = "Stack name"
  default     = "ARC-batch-stack"
}

variable "as2_stack_description" {
  type        = string
  description = "Stack description"
  default     = "ARC batch process stack"
}

variable "as2_stack_display_name" {
  type        = string
  description = "Stack diplay name"
  default     = "ARC batch process stack"
}
