variable "ec2_sg_allowed_ips" {
  description = "List of allowed IP addresses"
  type        = list(string)
  default     = []
}

variable ec2_security_group {}
