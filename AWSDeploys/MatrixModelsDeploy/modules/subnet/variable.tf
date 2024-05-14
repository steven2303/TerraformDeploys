variable "vpc_id" {
  description = "VPC ID for the RDS security group"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_newbits" {
  description = "The number of additional bits with which to extend the VPC CIDR block for each subnet"
  type        = number
  default     = 4
}

variable public_subnet_name {}
variable private_subnet_name {}