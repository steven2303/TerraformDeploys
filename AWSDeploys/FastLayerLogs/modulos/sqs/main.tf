resource "aws_sqs_queue" "sqs_audit_log_event_queue" {
  name                        = var.audit_log_sqs_queue_name
  delay_seconds               = 1
  max_message_size            = 10000
  message_retention_seconds   = 86400
  receive_wait_time_seconds   = 0
  visibility_timeout_seconds  = 60

  # Habilitar la encriptación
  kms_master_key_id = var.kms_audit_log_arn
  kms_data_key_reuse_period_seconds = 300
}

resource "aws_sqs_queue_policy" "sqs_audit_log_queue_policy" {
  queue_url = aws_sqs_queue.sqs_audit_log_event_queue.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "StmtS3ToSQSPolicy",
        Effect    = "Allow"
        Principal =  {
            Service =  "s3.amazonaws.com"
        }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.sqs_audit_log_event_queue.arn
        Condition = {
            ArnEquals = { "aws:SourceArn": "arn:aws:s3:::${var.audit_log_landing_bucket_name}" }
        }
      }
    ]
  })
}
