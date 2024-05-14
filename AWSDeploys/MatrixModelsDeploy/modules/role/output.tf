output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

output "lambda_vpc_access_policy_attachment_id" {
  value = aws_iam_role_policy_attachment.lambda_vpc_access.id
}

output "cross_account_api_access_role_name" {
  value = length(var.account_b_id) > 0 ? aws_iam_role.cross_account_api_access_role_name[0].name : ""
}

output "account_id"{
  value = data.aws_caller_identity.current.account_id
}