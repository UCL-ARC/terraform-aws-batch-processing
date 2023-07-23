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
variable "datasync_task_s3_efs" {
  type        = string
  description = "Datasync s3 to efs task arn"
}

variable "datasync_task_efs_s3" {
  type        = string
  description = "Datasync efs to s3 task arn"
}