terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "terraform-series-state" 
    key    = "s1e2/broken/terraform.tfstate"
    region = "us-east-1"
     dynamodb_table = "terraform-state-lock"  
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "s1e2-main-vpc"
    Environment = "simulation"
    Episode     = "S1E2"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name    = "s1e2-public-subnet-a"
    Episode = "S1E2"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name    = "s1e2-public-subnet-b"
    Episode = "S1E2"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "s1e2-igw"
    Episode = "S1E2"
  }
}

resource "aws_security_group" "web" {
  name        = "s1e2-web-sg"
  description = "Web security group for S1E2 simulation"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "s1e2-web-sg"
    Episode = "S1E2"
  }
}

