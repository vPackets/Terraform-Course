output "ec2_public_ip" {
    value = aws_instance.vPackets_ec2.public_ip
    description = "This is the public IP of the web server"
}

output "ec2_public_dns" {
    value = aws_instance.vPackets_ec2.public_dns
    description = "This is the public DNS of the web server"
}
