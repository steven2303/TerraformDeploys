resource "aws_api_gateway_rest_api" "tapi_api" {
  name        = var.api_name
  description = var.api_description
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "tapi_resource" {
  rest_api_id = aws_api_gateway_rest_api.tapi_api.id
  parent_id   = aws_api_gateway_rest_api.tapi_api.root_resource_id
  path_part   = var.resource_path
}
