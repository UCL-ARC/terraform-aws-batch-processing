output "datasync_task_s3_efs" {
  value       = aws_datasync_task.datasync_task_s3_efs.arn
  description = "Datasync s3 to EFS Task arn"
}
output "datasync_task_efs_s3" {
  value       = aws_datasync_task.datasync_task_efs_s3.arn
  description = "Datasync EFS to s3 Task arn"
}
