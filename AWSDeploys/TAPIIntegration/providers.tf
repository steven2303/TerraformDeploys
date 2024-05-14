terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2"
    }
  }
  required_version = "~>1.6.0"
}


provider "aws" {
  region = var.aws_region
  alias = "development"
  profile = var.perfil_despliegue
}

provider "archive" {}