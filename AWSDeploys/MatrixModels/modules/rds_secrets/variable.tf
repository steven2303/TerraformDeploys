variable "aurora_engine" {
  description = "The engine type for the Aurora cluster."
  type        = string
  default     = "aurora-postgresql"
}

variable "aurora_engine_version" {
  description = "The engine version for the Aurora cluster."
  type        = string
  default     = "14.6"
}

variable "aurora_database_name" {
  description = "The name of the database to be created in the Aurora cluster."
  type        = string
  default     = "fast_layer_db"
}

variable "aurora_master_username" {
  description = "The master username for the Aurora cluster."
  type        = string
}

variable "cluster_instance_count" {
  description = "The number of instances in the Aurora cluster."
  type        = number
  default     = 1
}

variable "aurora_instance_class" {
  description = "The instance class for the Aurora cluster instances."
  type        = string
  default     = "db.r5.large"
}

variable "private_subnet_ids" {
  description = "A list of subnet IDs to associate with the private route table"
  type        = list(string)
}

variable "aurora_security_group_id" {
  description = "The ID of the Aurora RDS security group"
  type        = string
}

variable "secrets_manager_secret_name" {
  description = "The name of the secret in AWS Secrets Manager"
  type        = string
}

variable "backup_retention_period" {}