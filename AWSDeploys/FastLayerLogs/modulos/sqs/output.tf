output "audit_log_sqs_queue_arn" {
  value = aws_sqs_queue.sqs_audit_log_event_queue.arn
  description = "The ARN of the SQS queue for audit log events"
}

# Output the SQS queue URL
output "sqs_queue_url" {
  value = aws_sqs_queue.sqs_audit_log_event_queue.url
}