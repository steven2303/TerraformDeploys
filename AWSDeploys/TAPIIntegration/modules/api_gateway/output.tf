output "tapi_resource_id" {
  value = aws_api_gateway_resource.tapi_resource.id
  description = "The ID of the 'tapi' resource"
}

output "tapi_api_id" {
  value       = aws_api_gateway_rest_api.tapi_api.id
  description = "The ID of the API Gateway"
}

output "tapi_api_arn" {
  value       = aws_api_gateway_rest_api.tapi_api.execution_arn
  description = "The ARN of the 'tapi_api' API Gateway"
}

output "tapi_resource_name" {
  value = aws_api_gateway_resource.tapi_resource.path_part
}