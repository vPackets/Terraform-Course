terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  profile = "vPackets"
}


resource "aws_instance" "foo" {
  ami           = "ami-00874d747dde814fa" # us-west-2
  instance_type = "t2.micro"
}


