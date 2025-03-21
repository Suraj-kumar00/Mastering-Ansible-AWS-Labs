# Define SSH Key Pair Name (Persist Key)
variable "key_name" {
  description = "Name of the SSH key pair"
  default     = "terraform-key"
}

# Load an existing SSH key from ~/.ssh instead of requiring it in the module
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = file("${var.home_directory}/.ssh/${var.key_name}.pub") # Dynamically reference public key
}

variable "home_directory" {
  description = "User's home directory path"
  default     = "/home/devopsbro"
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

# Create an Internet Gateway for Public Access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.default_vpc.id

  tags = {
    Name = "Default-IGW"
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

# Create a Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.default_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-RT"
  }
}

# Associate Public Subnet with the Route Table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
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

# Create EC2 Instance
resource "aws_instance" "web" {
  count         = 1  
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id  
  key_name      = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]

  tags = {
    Name = "Ansible-Managed-Server-${count.index + 1}"  
  }
}

# Assign Elastic IP to Keep the Same Public IP
resource "aws_eip" "elastic_ip" {
  instance = aws_instance.web[0].id
}

# Create EBS Volumes for each instance
resource "aws_ebs_volume" "storage" {
  count             = 1  
  availability_zone = var.availability_zone
  size              = 10
}

# Attach EBS Volumes to EC2 Instances
resource "aws_volume_attachment" "ebs_att" {
  count       = 1  
  device_name = "/dev/xvdf"
  instance_id = aws_instance.web[count.index].id
  volume_id   = aws_ebs_volume.storage[count.index].id
}
