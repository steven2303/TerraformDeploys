output "lambda_glue_status_monitor_function_arn" {
  value = aws_lambda_function.lambda_glue_status_monitor.arn
}

output "lambda_raw_sftp_s3_audit_log_mover_function_arn" {
  value = aws_lambda_function.lambda_raw_sftp_s3_audit_log_mover.arn
}

output "lambda_pgmmaster_log_processor_function_arn" {
  value = aws_lambda_function.lambda_pgmmaster_log_processor.arn
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}