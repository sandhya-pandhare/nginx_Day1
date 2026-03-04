terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.32.1"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}




resource "aws_vpc" "MY_VPC" {
  cidr_block           = "171.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "Devops_VPC"
  }

}

resource "aws_subnet" "main1" {
  vpc_id                  = aws_vpc.MY_VPC.id
  cidr_block              = "171.0.0.0/17"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true


  tags = {
    Name = "Devops_SUB1"
  }
}

resource "aws_subnet" "main2" {
  vpc_id                  = aws_vpc.MY_VPC.id
  cidr_block              = "171.0.128.0/18"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true


  tags = {
    Name = "Devops_SUB2"
  }
}


resource "aws_subnet" "main3" {
  vpc_id                  = aws_vpc.MY_VPC.id
  cidr_block              = "171.0.192.0/27"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true


  tags = {
    Name = "Devops_SUB3"
  }
}



resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.MY_VPC.id
  tags = {
    Name = "Devops_IGW"
  }
  
}


resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.MY_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "Devops_RT"
  }

  
}



resource "aws_route_table_association" "rt1" {
  subnet_id = aws_subnet.main1.id
  route_table_id = aws_route_table.main_rt.id
  
}

resource "aws_route_table_association" "rt2" {
  subnet_id = aws_subnet.main2.id
  route_table_id = aws_route_table.main_rt.id
  
}

resource "aws_route_table_association" "rt3" {
  subnet_id = aws_subnet.main3.id
  route_table_id = aws_route_table.main_rt.id
  
}



resource "aws_security_group" "newsec" {
  name        = "automation_security"
  description = "iam creatiing a new security"
  vpc_id      = aws_vpc.MY_VPC.id

  #inbound
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #equivalent to all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_key_pair" "ec2_key" {
  key_name   = "sandhya1012"
  public_key = file("ec2_key.pub")
}

resource "aws_instance" "myec2" {
  ami                    = "ami-019715e0d74f695be"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.main1.id
  vpc_security_group_ids = [aws_security_group.newsec.id]
  key_name               = aws_key_pair.ec2_key.id
  user_data              = file("file.sh")


  tags = {
    Name = "Devops_instance"
  }


}

output "public_ip" {
  value = aws_instance.myec2.public_ip

}