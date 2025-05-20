output "security_group_id" {
  value = module.web_server_sg.security_group_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}