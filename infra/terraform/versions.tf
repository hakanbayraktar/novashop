terraform {
  required_version = ">= 1.10.0"

  # The bucket is created once before this stack is used. CI supplies its
  # name with -backend-config; state must never live on an Actions runner.
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.tags
  }
}
