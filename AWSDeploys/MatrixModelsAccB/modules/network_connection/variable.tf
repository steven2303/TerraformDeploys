variable "vpc_id" {
  description = "VPC ID for the RDS security group"
  type        = string
}

variable "first_public_subnet_id" {
  description = "The ID of the first public subnet"
  type        = string
}

variable "private_route_table_id" {
  description = "The ID of the private route table associated with the VPC"
  type        = string
}

variable "endpoint_subnet_id" {
  description = "Subnet ID for the endpoint"
  type        = string
}

variable "lambda_security_group_id" {
  description = "The ID of the Lambda security group"
  type        = string
}