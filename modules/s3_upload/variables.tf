
variable "acl_value" {
  type        = string
  default     = "private"
  description = "Access control list"
}

variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "The region to deploy into."
}

variable "bucket_name" {
  type        = string
  description = "Overall name for the bucket"
}