module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/24"

  azs                               = ["ap-southeast-2a", "ap-southeast-2b"]
  private_subnets                   = ["10.0.0.0/28", "10.0.0.16/28"]
  public_subnets                    = ["10.0.0.32/28", "10.0.0.64/28"]
  map_public_ip_on_launch           = true
  
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

