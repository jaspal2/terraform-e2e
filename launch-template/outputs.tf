output "launch_template_id" {
    value = aws_launch_template.terraform_template.id
}


output "public_subnets"{
    value = module.vpc.public_subnets
}