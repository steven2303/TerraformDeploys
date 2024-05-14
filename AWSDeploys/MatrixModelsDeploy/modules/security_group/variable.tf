variable "vpc_id" {
  description = "VPC ID for the RDS security group"
  type        = string
}

variable "aurora_sg_allowed_ips" {
  description = "List of allowed IP addresses"
  type        = list(string)
  default     = []
}

variable lambda_security_group {}
variable arurora_security_group {}