resource "aws_iam_role" "cross_account_api_access_role_name" {
  count = length(var.account_b_id) > 0 ? 1 : 0
  name = "ue1seg${var.stage_name}rolflm002" 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_b_id}:role/${var.lambda_execution_role_name_account_b}"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "api_access_policy" {
  count = length(var.account_b_id) > 0 ? 1 : 0
  name        = "ue1seg${var.stage_name}polflm006"
  description = "Allows cross-account access to invoke the API in this Account"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "execute-api:Invoke",
        Effect   = "Allow",
        Resource = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_access_policy_attachment" {
  count = length(var.account_b_id) > 0 ? 1 : 0
  role       = aws_iam_role.cross_account_api_access_role_name[0].name
  policy_arn = aws_iam_policy.api_access_policy[0].arn
}
