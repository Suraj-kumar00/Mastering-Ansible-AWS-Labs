# Output Elastic IPs of the created EC2 instances & SSH command to connect to the instance
output "elastic_ip" {
  description = "Elastic IP of the EC2 instance"
  value       = aws_eip.elastic_ip.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${var.home_directory}/.ssh/${var.key_name} ubuntu@${aws_eip.elastic_ip.public_ip}"
}
