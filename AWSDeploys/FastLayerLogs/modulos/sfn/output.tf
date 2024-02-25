output "sfn_state_machine_arn" {
  value = aws_sfn_state_machine.sfn_log_processing_state_machine.arn
  description = "The ARN of the Step Functions State Machine"
}