variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "my_project"
}

variable "aws_region" {
  description = "The name of the AWS Region"
  type        = string
}

variable "subnet_newbits" {
  description = "The number of additional bits with which to extend the VPC CIDR block for each subnet"
  type        = number
  default     = 4
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "internet_cidr_block" {
  description = "CIDR block for routing internet traffic"
  type        = string
}

variable "aurora_sg_allowed_ips" {
  description = "List of allowed IP addresses"
  type        = list(string)
  default     = []
}


variable "stage_name" {
  description = "The name of the deployment stage"
  type        = string
}

variable "perfil_despliegue"{
  type        = string
}

variable "account_a_id" {
  description = "The AWS Account ID of Account A"
  type        = string
}

variable "lambda_execution_role_name_account_a" {
  description = "The name of the IAM role for Lambda execution in Account A"
  type        = string
  default     = "LambdaExecutionRole"
}