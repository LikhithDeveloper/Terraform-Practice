terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.44.0"

    }
  }
  required_version = ">=1.15.2"
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "test_bucket" {
  bucket = "test-demo-bucket-likhith"
  tags = {
    name = "Likhith"
  }
}
