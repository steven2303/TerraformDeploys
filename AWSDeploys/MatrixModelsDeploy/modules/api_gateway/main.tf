resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = var.api_description
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = var.resource_path
}

resource "aws_api_gateway_rest_api_policy" "api_policy" {
  count = length(var.lambda_execution_role_name_account_b) > 0 ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.api.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_b_id}:role/${var.lambda_execution_role_name_account_b}"
        }
        Action   = "execute-api:Invoke"
        Resource = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*"
      },
    ]
  })
}