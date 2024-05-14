output "dependencias_layer_arn" {
  value       = aws_lambda_layer_version.dependencias.arn
  description = "The ARN of the 'dependencias' Lambda layer version"
}