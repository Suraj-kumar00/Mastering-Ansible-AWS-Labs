# To Generate Private Key
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Define SSH Key Pair Name
variable "key_name" {
  description = "Name of the SSH key pair"
  default     = "terraform-key"
}

# Create AWS Key Pair for EC2 SSH Access
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh
}

# Save Private Key Locally
resource "local_file" "private_key" {
  content  = tls_private_key.rsa_4096.private_key_pem
  filename = "${path.module}/${var.key_name}.pem"
  file_permission = "0600"
}

# Create a Security Group for EC2
resource "aws_security_group" "sg_ec2" {
  name        = "sg_ec2"
  description = "Security group for EC2"
  vpc_id      = aws_vpc.default_vpc.id

  # Allow SSH from anywhere (Modify CIDR for more security)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a Default VPC (if it doesn't exist)
resource "aws_vpc" "default_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Default-VPC"
  }
}

# Create a Public Subnet inside the VPC
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.default_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true  # Assigns public IP

  tags = {
    Name = "Public-Subnet"
  }
}

# Create EC2 Instances using the generated key
resource "aws_instance" "web" {
  count         = 2  
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id  
  key_name      = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]

  tags = {
    Name = "Ansible-Managed-Server-${count.index + 1}"  
  }
}

# Create EBS Volumes for each instance
resource "aws_ebs_volume" "storage" {
  count             = 2  
  availability_zone = var.availability_zone
  size              = 10
}

# Attach EBS Volumes to EC2 Instances
resource "aws_volume_attachment" "ebs_att" {
  count       = 2  
  device_name = "/dev/xvdf"
  instance_id = aws_instance.web[count.index].id
  volume_id   = aws_ebs_volume.storage[count.index].id
}
