variable "batch_task_arn" {
  type        = string
  description = "Batch Task arn"
}
variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "The region to deploy into."
}
variable "batch_job_queues" {
  type        = map(any)
  description = "Batch Job Queue"
  default = {
    "job_queues" = "HighPriority"
  }
}
