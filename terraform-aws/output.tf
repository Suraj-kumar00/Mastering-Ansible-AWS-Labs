# Output Public IPs of the created EC2 instances
output "ec2_public_ips" {
  description = "Public IP addresses of the EC2 instances"
  value       = aws_instance.web[*].public_ip
}

# Output SSH command for quick access
output "ssh_commands" {
  description = "Copy and paste this to SSH into the instances"
  value       = [for ip in aws_instance.web[*].public_ip : "ssh -i ${path.module}/${var.key_name}.pem ubuntu@${ip}"]
}
