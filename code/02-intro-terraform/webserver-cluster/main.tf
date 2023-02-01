terraform {
  required_version = ">=1.0.0"

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


data "aws_vpc" "default" {
  default = true  
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
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

resource "aws_security_group" "vPackets-SG-ALB" {
    name = var.alb_security_group_name
    
    ingress {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "Allow inbound HTTP requests"
      from_port = 80
      to_port = 80
      protocol = "tcp"
    } 
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }


}

resource "aws_launch_configuration" "ec2_launch_config" {
  name_prefix   = "vPackets-ec2-launch-config"
  image_id      = var.ec2_instance_ami
  instance_type = var.ec2_instance_type
  
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.security_group_server_port} & 
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ec2_autoscaling-group" {
  name                 = "ec2_autoscaling-group"
  launch_configuration = aws_launch_configuration.ec2_launch_config.name
  vpc_zone_identifier  = data.aws_subnets.default.ids
  min_size             = 2
  max_size             = 3

  tag {
    key  = "name"
    value = "autoscaling-group-example"
    propagate_at_launch = true
  }
}


resource "aws_lb" "load_balancer_front_end" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.vPackets-SG-ALB.id]
  subnets            = data.aws_subnets.default.ids
}


resource "aws_lb_listener" "load_balancer_listener_front_end" {
  load_balancer_arn = aws_lb.load_balancer_front_end.arn
  port              = 80
  
  default_action {
    type             = "fixed-response"
    
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found :("
      status_code = 404
    }
  }
}


resource "aws_lb_target_group" "load_balancer_lb_target_group" {
  name     = var.alb_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

resource "aws_lb_listener_rule" "load_balancer_lb_listener_rule" {
  listener_arn = aws_lb_listener.load_balancer_listener_front_end.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.load_balancer_lb_target_group.arn
  }
}