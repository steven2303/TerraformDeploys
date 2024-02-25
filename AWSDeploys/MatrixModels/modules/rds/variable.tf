variable "private_subnet_ids" {
  description = "List of private subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the RDS security group"
  type        = string
}

variable "instance_count" {
  description = "Number of RDS cluster instances to create"
  type        = number
  default     = 1
}

variable "instance_class" {
  description = "Instance class for the RDS cluster instances"
  type        = string
  default     = "db.t3.medium"
}