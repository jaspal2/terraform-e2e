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


resource "aws_launch_template" "ec2_template" {
  name = "foo"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }


  cpu_options {
    core_count       = 4
    threads_per_core = 2
  }

  credit_specification {
    cpu_credits = "standard"
  }


  image_id = data.aws_ami.ubuntu_ami.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t2.micro"

  kernel_id = "test"

  key_name = "test"


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

  # Autoscaling group
  name = "example-asg"

  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = [modue.vpc.vpc_id]


  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 600
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 300
      min_healthy_percentage = 50
      max_healthy_percentage = 100
    }
    triggers = ["tag"]
  }

  # Launch template
  launch_template_name        = "new-template"
  launch_template_description = "Launch template example"
  update_default_version      = true

  image_id          = "data.aws_ami.id"
  instance_type     = "t3.micro"
  enable_monitoring = true

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        volume_type           = "gp2"
      }
    }
  ]
  cpu_options = {
    core_count       = 1
    threads_per_core = 1
  }

 
  tags = {
    Environment = "dev"
    Project     = "megasecret"
  }
}

