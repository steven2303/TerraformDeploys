output "glue_audit_log_job_name" {
  value = aws_glue_job.glue_audit_log_etl_job.name
}

output "glue_audit_log_crawler_name" {
  value = aws_glue_crawler.glue_audit_log_crawler.name
}