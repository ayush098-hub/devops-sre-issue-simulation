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


data "aws_vpc" "existing_vpc" {
  tags = {
    Name = "my-vpc"
  }
}

# Look up an existing public subnet within that VPC
data "aws_subnet" "existing_subnet" {
  vpc_id = data.aws_vpc.existing_vpc.id
  tags = {
    Name = "my-public-subnet-1"
  }
}

# Example resource creation (an S3 bucket)
resource "aws_instance" "example" {
  ami           = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = "t2.micro"
  subnet_id = data.aws_subnet.existing_subnet.id

  tags = {
    Name = "HelloWorld"
  }
}