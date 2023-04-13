output "sfn_state_machine_arn" {
  description = "The ARN of the Step Function"
  value       = module.step_function.state_machine_arn
}
