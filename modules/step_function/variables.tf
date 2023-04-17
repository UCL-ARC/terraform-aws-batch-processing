variable "batch_task_arn" {
  type        = string
  description = "Batch Task arn"
}
variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "The region to deploy into."
}
variable "batch_job_definitions" {
  type        = map(any)
  description = "Batch Job Definition"
  default = {
    "name" = "arc-batch"
  }
}
variable "batch_job_queues" {
  type        = map(any)
  description = "Batch Job Queue"
  default = {
    "job_queues" = "HighPriority"
  }
}