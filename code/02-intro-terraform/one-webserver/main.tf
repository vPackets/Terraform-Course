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
    name = "vPackets-SG-TEST"

    ingress {
        from_port   =  8080
        to_port     =  8080
        protocol    =  "tcp"
        cidr_blocks =  ["0.0.0.0/0"]
    }
}

resource "aws_instance" "vPackets_ec2" {
  ami           = "ami-00874d747dde814fa"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.vPackets-SG-TEST.id] # This is a reference.

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  user_data_replace_on_change = true
  

  tags = {
    name = "vPackets - EC2"
  }
}

output "vPackets-instances" {
  value = "${aws_instance.vPackets_ec2.*.public_ip}"
  description = "Public IP is: "
}