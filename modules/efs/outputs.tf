output "mount_targets" {
  value       = module.efs.mount_targets
  description = "EFS mount targets"
}
output "access_points" {
  value       = module.efs.access_points
  description = "EFS access points"
}
output "efs_id" {
  value       = module.efs.id
  description = "EFS ID"
}
output "efs_arn" {
  value       = module.efs.arn
  description = "EFS ID"
}
output "efs_security_group_arn" {
  value       = module.efs.security_group_arn
  description = "EFS ID"
}
