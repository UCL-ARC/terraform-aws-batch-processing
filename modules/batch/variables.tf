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
  description = "Container vCPUs resources"
  default     = 1.0
}
variable "container_memory" {
  type        = number
  description = "Container Memory resources"
  default     = 2048
}
variable "efs_id" {
  type        = string
  description = "EFS ID"
}
