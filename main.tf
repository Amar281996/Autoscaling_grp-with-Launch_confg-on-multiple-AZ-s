#create Vpc for Asg
resource "aws_vpc" "main" {
    cidr_block = "172.66.0.0/16"
    tags = {
      Name = "Asg"
    }
}
# use existing availability_zones
data "aws_availability_zones" "available" {
  state = "available"
}
#create subnets
resource "aws_subnet" "primary" {
    vpc_id = aws_vpc.main.id
    availability_zone = data.aws_availability_zones.available.names[0]
    cidr_block = "172.66.1.0/24"

    tags = {
      Name = "Asg_sub1"
    }
    
}


resource "aws_subnet" "secondary" {
    vpc_id = aws_vpc.main.id
    availability_zone = data.aws_availability_zones.available.names[1]
    cidr_block = "172.66.2.0/24"

    tags = {
      Name = "Asg_sub2"
    }
   
}
#create Security group 
resource "aws_security_group" "ec2_secgrp" {
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "srs-ec2-secgrp"
    }
 } 
#use existing ami's using datasources
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
#create launch_configuration

resource "aws_launch_configuration" "asg_conf" {
  name_prefix   = "terraform-lc-example-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}
#create Auto scaling group
resource "aws_autoscaling_group" "ASG-exam" {
  availability_zones = ["eu-west-1a","eu-west-1c"]
  name                 = "terraform-asg-amar"
  launch_configuration = aws_launch_configuration.asg_conf.name
  desired_capacity   = 1
  min_size             = 1
  max_size             = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true

  lifecycle {
    create_before_destroy = true
  }
}

