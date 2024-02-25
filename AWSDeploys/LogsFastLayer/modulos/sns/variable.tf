variable "email_endpoints" {
  description = "List of email addresses for ETL job status notifications"
  type        = list(string)
}

variable "sns_etl_job_topic_name" {
  description = "The name of the SNS topic for ETL job notifications"
  type        = string
}
