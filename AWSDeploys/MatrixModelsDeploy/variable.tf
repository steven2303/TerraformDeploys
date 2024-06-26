variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "my_project"
}

variable "aws_region" {
  description = "The name of the AWS Region"
  type        = string
}

variable "account_b_id" {
  description = "The AWS Account ID of Account B"
  type        = string
}

variable "lambda_execution_role_name_account_b" {
  description = "The name of the IAM role for Lambda execution in Account B"
  type        = string
  default     = "LambdaExecutionRole"
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

variable "s3_matrix_models_bucket_name" {
  description = "The name of the S3 bucket for matrix models"
  type        = string
}

variable "stage_name" {
  description = "The name of the deployment stage"
  type        = string
}

variable backup_retention_period {}
#variable s3_resources_bucket_name {}
variable prefix_recommender {}
variable prefix_profile {}
variable prefix_churn {}
variable prefix_new_partner {}
variable prefix_re_entry {}
variable perfil_despliegue {}
variable s3_ddl_key {}

variable prefix_canje {}
variable prefix_detalle_canje {}
variable prefix_cliente {}
variable prefix_processing_artifacts {}
variable prefix_sku_catalog {}