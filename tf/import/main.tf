terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # It is a best practice to pin your provider version
    }
  }
}

# Configure the AWS Provider with a default region
provider "aws" {
  region = "us-east-1"
}

# Example resource creation (an S3 bucket)
resource "aws_s3_bucket" "bucket-created-without-tf" {
    bucket = "bucket-created-without-tf"
}
