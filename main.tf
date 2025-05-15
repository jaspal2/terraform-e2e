data "aws_ami" "ubuntu_ami" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20250305"]
  }


  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


## VPC Module

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/24"

  azs                               = ["ap-southeast-2a", "ap-southeast-2b"]
  private_subnets                   = ["10.0.0.0/28", "10.0.0.16/28"]
  public_subnets                    = ["10.0.0.32/28", "10.0.0.64/28"]
  
  create_igw      = true  
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


# AWS security group module
module "web_server_sg" {
 source = "terraform-aws-modules/security-group/aws"

  name        = "vpc_public_SG"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id
  ingress_cidr_blocks      =    ["0.0.0.0/0"]
  ingress_rules            = ["https-443-tcp", "http-80-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh port"
      cidr_blocks = "0.0.0.0/0"
    }]
 }

resource "aws_launch_template" "terraform_template" {
  name = "terrafomr_template"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }
  image_id = data.aws_ami.ubuntu_ami.id

  vpc_security_group_ids = [module.web_server_sg.security_group_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }

}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 7.0" # use latest version compatible with your setup

  name = "terraform-asg-module"

  vpc_zone_identifier = ["subnet-020435553a8d8a35b"]  # Replace with your subnet IDs
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1

  use_launch_template = true

    launch_template_id   = aws_launch_template.terraform_template.id
     launch_template_version          = "$Latest"

  health_check_type         = "EC2"
  health_check_grace_period = 300
  wait_for_capacity_timeout = "0"

  tags = [
    {
      key                 = "Name"
      value               = "asg-instance"
      propagate_at_launch = true
    }
  ]
}
