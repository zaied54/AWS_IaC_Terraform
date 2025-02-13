provider "aws" {
  profile = "default"  
  region  = "us-west-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_iam_role" "dev_role" {
  name = "dev-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role" "prod_role" {
  name = "prod-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_instance_profile" "dev_instance_profile" {
  name = "dev-instance-profile"
  role = aws_iam_role.dev_role.name
}

resource "aws_iam_instance_profile" "prod_instance_profile" {
  name = "prod-instance-profile"
  role = aws_iam_role.prod_role.name
}

resource "aws_instance" "dev-vm" {
  ami           = "ami-0454207e5367abf01"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet1.id
  iam_instance_profile = aws_iam_instance_profile.dev_instance_profile.name
  key_name      = "dev-key-pair"  # Ensure this key pair is created in AWS
}

resource "aws_instance" "prod-vm" {
  ami           = "ami-0454207e5367abf01"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet2.id
  iam_instance_profile = aws_iam_instance_profile.prod_instance_profile.name
  key_name      = "prod-key-pair"  # Ensure this key pair is created in AWS
}