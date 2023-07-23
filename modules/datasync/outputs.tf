output "datasync_task_s3_efs" {
  value       = aws_datasync_task.datasync_task_s3_efs.arn
  description = "Datasync Task arn"
}
