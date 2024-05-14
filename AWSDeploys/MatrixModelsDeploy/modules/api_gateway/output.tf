output "tapi_resource_id" {
  value = aws_api_gateway_resource.resource.id
  description = "The ID of the 'tapi' resource"
}

output "tapi_api_id" {
  value       = aws_api_gateway_rest_api.api.id
  description = "The ID of the API Gateway"
}

output "tapi_api_arn" {
  value       = aws_api_gateway_rest_api.api.execution_arn
  description = "The ARN of the 'tapi_api' API Gateway"
}

output "tapi_resource_name" {
  value = aws_api_gateway_resource.resource.path_part
}