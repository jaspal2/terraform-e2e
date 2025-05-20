output "security_group_id" {
  value = module.web_server_sg.security_group_id
}

output "public_subnets" {
  value = moduel.vpc.public_subnets
}