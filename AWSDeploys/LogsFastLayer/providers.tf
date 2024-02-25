terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.31.0"
    }
  }
    required_version = "~>1.6.0"
}

provider "aws" {
  region = "us-west-2"
  alias = "virginia"
  ##profile = "bonus_account"
}