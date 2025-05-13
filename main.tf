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
#module "web_server_sg" {
#  source = "terraform-aws-modules/security-group/aws"

#  name        = "vpc_public_SG"
#  description = "Security group for web-server with HTTP ports open within VPC"
#  vpc_id      = module.vpc.vpc_id
#
#  ingress_rules            = ["https-443-tcp", "http-80-tcp", "ssh-tcp"]
 

#}


module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "user-service"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["10.10.0.0/16"]
  ingress_rules            = ["https-443-tcp"]
  
}

# AWS aws_launch_template

resource "aws_launch_template" "ec2_template" {
  name = "ec2_template_ubuntu"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }

  image_id = data.aws_ami.ubuntu_ami.id

  instance_type = "t2.micro"

  vpc_security_group_ids = [module.web_server_sg.security_group_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }

}