variable "solution_name" {
  type        = string
  description = "Overall name for the solution"
}
variable "efs_id" {
  type        = string
  description = "EFS ID"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}
variable "private_subnets" {
  type        = list(string)
  description = "VPC private subnets' IDs list"
}
variable "compute_environments" {
  type        = string
  description = "Compute environments"
  default     = "fargate"
}

variable "compute_resources_max_vcpus" {
  type        = number
  description = "Max VCPUs resources"
}