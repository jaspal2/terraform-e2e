output "launch_template_id" {
    value = aws_launch_template.terraform_template.id
}

# Module 2 (Launch Template) outputs.tf
output "vpc" {
  value       = module.vpc
  description = "All outputs from the VPC module"
}