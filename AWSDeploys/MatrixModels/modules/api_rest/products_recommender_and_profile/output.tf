output "invoke_url_api1" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.stage_name}/${var.resource_path}"
}

output "api_id" {
  value = aws_api_gateway_rest_api.api.id
  description = "The ID of the API Gateway REST API"
}
