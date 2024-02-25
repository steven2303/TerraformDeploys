resource "aws_lambda_function" "lambda_s3_event_state_machine_trigger" {
  function_name = var.lambda_s3_event_trigger_function_name
  handler       = "TriggerStateMachineFromS3Event.lambda_handler"
  runtime       = "python3.10"
  filename = "Scripts/TriggerStateMachineFromS3Event.zip"

  # IAM role that the Lambda function assumes during execution.
  role = aws_iam_role.lambda_role.arn

  # Memory and timeout settings.
  memory_size = 128  # in MB
  timeout     = 30   # in seconds
  
  # Environment variables
  environment {
    variables = {
      STATE_MACHINE_ARN = var.sfn_state_machine_arn
      LOG_DESTINATION = var.glue_s3_audit_log_destination_location
      ERROR_DESTINATION = var.glue_s3_audit_log_error_location
      SQS_QUEUE_URL = var.sqs_queue_url
    }
  }
}

resource "aws_lambda_function" "lambda_glue_status_monitor" {
  function_name = var.lambda_glue_status_monitor_function_name
  handler       = "CheckGlueJobStatus.lambda_handler"
  runtime       = "python3.10"
  filename = "Scripts/CheckGlueJobStatus.zip"

  # IAM role that the Lambda function assumes during execution.
  role = aws_iam_role.lambda_role.arn

  # Memory and timeout settings.
  memory_size = 128  # in MB
  timeout     = 30   # in seconds
}

resource "aws_lambda_permission" "lambda_permission_sqs_invoke" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_s3_event_state_machine_trigger.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = var.audit_log_sqs_queue_arn 
}

resource "aws_lambda_event_source_mapping" "lambda_sqs_audit_log_event_mapping" {
  event_source_arn  = var.audit_log_sqs_queue_arn 
  function_name     = aws_lambda_function.lambda_s3_event_state_machine_trigger.arn
  enabled           = true
  batch_size        = 1 # Número de mensajes procesados en un lote
}

resource "aws_lambda_function" "lambda_raw_sftp_s3_audit_log_mover" {
  function_name = var.lambda_raw_sftp_s3_audit_log_mover_function_name
  handler       = "S3RawSFTPAuditLogMover.lambda_handler"
  runtime       = "python3.10"
  filename = "Scripts/S3RawSFTPAuditLogMover.zip"

  # IAM role that the Lambda function assumes during execution.
  role = aws_iam_role.lambda_role.arn 

  # Memory and timeout settings.
  memory_size = 128  # in MB
  timeout     = 30   # in seconds
  
  # Environment variables
  environment {
    variables = {
      KEY_TO_LOG = var.audit_log_landing_bucket_prefixes[0]
      KEY_TO_MASTER = var.audit_log_landing_bucket_prefixes[1]
      BUCKET_TO = var.audit_log_landing_bucket_name
    }
  }
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_raw_sftp_s3_audit_log_mover.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.sftp_audit_log_bucket_name}"
}

resource "aws_lambda_function" "lambda_pgmmaster_log_processor" {
  function_name = var.lambda_pgmmaster_log_processor_function_name
  handler       = "PGMMasterLogProcessor.lambda_handler"
  runtime       = "python3.10"
  filename = "Scripts/PGMMasterLogProcessor.zip"

  # Specify the layer using its ARN
  layers = ["arn:aws:lambda:${data.aws_region.current.name}:336392948345:layer:AWSSDKPandas-Python310:8"]

  # IAM role that the Lambda function assumes during execution.
  role = aws_iam_role.lambda_role.arn 

  # Memory and timeout settings.
  memory_size = 128  # in MB
  timeout     = 30   # in seconds
  
  # Environment variables
  environment {
    variables = {
      LOCATION_TO = var.lambda_s3_pgmmaster_log_destination_location
    }
  }
}

resource "aws_lambda_permission" "allow_s3_invoke_master_log" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_pgmmaster_log_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.audit_log_landing_bucket_name}"
}
