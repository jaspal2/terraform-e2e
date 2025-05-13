data "aws_ami" "ubuntu_ami" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu-noble-24.04-amd64-server"]
  }


  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/24"

  azs                               = ["ap-southeast-2a", "ap-southeast-2b"]
  private_subnets                   = ["10.0.0.0/28", "10.0.0.16/28"]
  public_subnets                    = ["10.0.0.32/28", "10.0.0.64/28"]
  default_security_group_name       =  "public_sg1"
  default_security_group_ingress    = [
    {
      description = "Allow HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }]
  create_igw      = true  
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


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

  placement {
    availability_zone = "us-west-2a"
  }

  vpc_security_group_ids = [module.vpc.default_security_group_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }

}