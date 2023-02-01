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

resource "aws_security_group" "vPackets-SG-TEST" {
    name = var.security_group_name

    ingress {
        from_port   =  var.security_group_server_port
        to_port     =  var.security_group_server_port
        protocol    =  var.security_group_server_port_protocol
        cidr_blocks =  var.security_group_cidr_block
    }
}

resource "aws_instance" "vPackets_ec2" {
  ami           = var.ec2_instance_ami
  instance_type = var.ec2_instance_type
  vpc_security_group_ids = [aws_security_group.vPackets-SG-TEST.id] # This is a reference.

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.security_group_server_port} & 
              EOF

  user_data_replace_on_change = true
  

  tags = {
    name = var.ec2_instance_name
  }
}
 
