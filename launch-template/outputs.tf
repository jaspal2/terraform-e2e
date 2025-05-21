output "launch_template_id" {
    value = aws_launch_template.terraform_template.id
}


output "public_subnets"{
    value = module.vpc.public_subnets
}

output "vpc_id" {
    value = "module.vpc.vpc_id"
}

output "security_group_id" {
    value = "module.web_server_sg.security_group_id"
}