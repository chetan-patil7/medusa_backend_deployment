terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "medusa-tf-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "medusa-tf-lock"
  }
}

provider "aws" {
  region = var.aws_region
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
