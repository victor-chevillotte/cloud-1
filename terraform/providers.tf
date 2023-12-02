terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.26.0"
    }
    ionosdeveloper = {
      source = "ionos-developer/ionosdeveloper"
      version = "0.0.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}