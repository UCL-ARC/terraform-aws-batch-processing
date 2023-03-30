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
