
output "rds_instance_creation_rule_arn" {
  value = aws_cloudwatch_event_rule.rds_instance_creation_rule.arn
}