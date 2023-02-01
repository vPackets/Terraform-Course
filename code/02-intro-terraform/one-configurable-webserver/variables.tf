variable "security_group_name" {
    description = "This is the name given to the security group name"
    type = string
    default = "vPackets-Security-Group-test"
  
}

variable "security_group_server_port" {
    description = "This is the value used to query the webserver"
    type = number
    default = 8080
}

variable "security_group_server_port_protocol" {
    description = "This is the prorotocol type used. Should be TCP"
    type = string
    default = "tcp"
}

variable "security_group_cidr_block" {
    description = "This is the CIDR block allowed to make requests"
    type = list
    default = ["0.0.0.0/0"]
}


variable "ec2_instance_ami" {
    description = "This is the AMI used for the EC2 instance in the region US-EAST-1"
    type = string
    default = "ami-00874d747dde814fa"
}

variable "ec2_instance_type" {
    description = "This is the T-Shirt Sized used "
    type = string
    default = "t2.micro"
}

variable "ec2_instance_name" {
    description = "This is the name given to the EC2 instance"
    type = string
    default = "vPackets - EC2"
}