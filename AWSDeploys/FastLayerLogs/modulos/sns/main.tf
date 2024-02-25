resource "aws_sns_topic_subscription" "sns_etl_job_email_subscription" {
  for_each   = toset(var.email_endpoints)
  topic_arn = aws_sns_topic.sns_etl_job_topic.arn
  protocol  = "email"
  endpoint   = each.value
}

resource "aws_sns_topic" "sns_etl_job_topic" {
  name = var.sns_etl_job_topic_name
  # Habilitar la encriptación
  kms_master_key_id = "alias/aws/sns"
}
