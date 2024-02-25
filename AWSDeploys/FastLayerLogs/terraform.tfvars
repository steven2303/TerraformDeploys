glue_audit_log_job_name       = "AuditLogDataETL"
glue_audit_log_database_name  = "audit_logs_db"
glue_audit_log_crawler_name   = "audit_logs_crawler"
lambda_pgmmaster_log_processor_function_name = "PGMMasterLogProcessor"
lambda_s3_event_trigger_function_name    = "TriggerStateMachineFromS3Event"
lambda_glue_status_monitor_function_name = "CheckGlueJobStatus"
sns_etl_job_topic_name = "audit_log_etl_job_status_notifications"
audit_log_sqs_queue_name    = "audit_logs_processing_queue"
sfn_state_machine_name    = "AuditLogProcessingStateMachine"
lambda_raw_sftp_s3_audit_log_mover_function_name = "S3RawSFTPAuditLogMover"
# Emails Notificacion
email_endpoints    = ["ssilvestre@millev.com"]
# Rutas s3
s3_audit_logs_processed_bucket_name = "ue1stgprdas3log002"
sftp_audit_log_bucket_name = "ue1stgdesaas3ftp001-test"
sftp_audit_log_bucket_prefixes = ["RAW-SFTP/LOGS/AUDIT_LOG/DELTA/","RAW-SFTP/LOGS/CAT_PRO/"]
audit_log_landing_bucket_name    = "ue1stgprdas3log001-test"
audit_log_landing_bucket_prefixes = ["LOGS/AUDIT_LOGS/DELTA/","LOGS/CAT_PRO/"]
glue_audit_log_script_location_s3 = "s3://ue1stgprdas3log003/scripts/AuditLogDataETL.py"
glue_audit_log_crawler_paths  = ["audit-logs/","cat-pro/"] # Primer elemento debe ser destino de los logs - segundo de la maestra de programas
glue_s3_audit_log_error_location = "error/"
# Roles
glue_audit_log_iam_role_arn = ""
lambda_audit_log_iam_role_arn = ""
sfn_audit_log_iam_role_arn = ""