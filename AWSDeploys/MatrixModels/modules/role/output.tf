output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

output "lambda_vpc_access_policy_attachment_id" {
  value = aws_iam_role_policy_attachment.lambda_vpc_access.id
}

output "cross_account_api_access_role_name" {
  value = aws_iam_role.cross_account_api_access_role_name.name
}

output "account_id"{
  value = data.aws_caller_identity.current.account_id
}