module "launch_template" {
  source = "./launch-template"
}


module "create_ASG" {
  source = "./terraform-aws-autoscaling-master/terraform-aws-autoscaling-master/"
  create_launch_template = false
  launch_template_id        = module.launch_template.launch_template_id
}