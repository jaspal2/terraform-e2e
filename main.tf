module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/24"

  azs             = ["ap-southeast-2a", "ap-southeast-2b"]
  private_subnets = ["10.0.0.0/28", "10.0.0.16/28"]
  public_subnets  = ["10.0.0.32/28", "10.0.0.64/28"]
  create_igw      = true  
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}