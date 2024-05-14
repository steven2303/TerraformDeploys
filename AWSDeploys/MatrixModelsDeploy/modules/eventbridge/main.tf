
resource "aws_cloudwatch_event_rule" "rds_instance_creation_rule" {
  name        = var.rds_creation_event_rule_name
  description = "Trigger Lambda on RDS instance creation in specific Aurora cluster"
  event_pattern = jsonencode({
    "source" : ["aws.rds"],
    "detail-type" : ["RDS DB Instance Event"],
    "detail" : {
      "EventCategories" : ["creation"]
    }
  })
}

resource "aws_cloudwatch_event_target" "invoke_lambda_on_rds_creation" {
  rule      = aws_cloudwatch_event_rule.rds_instance_creation_rule.name
  target_id = "invokeLambdaFunction"
  arn       = var.lambda_execute_sql_ddl_arn
}