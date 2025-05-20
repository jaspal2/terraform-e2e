module "launch_template" {
  source = "./launch-template"
}


module "create_ASG" {
  source = "./terraform-aws-autoscaling-master/terraform-aws-autoscaling-master/"
  name = "Terrafomr_asg"
  create_launch_template = false
  launch_template_id        = module.launch_template.launch_template_id
  min_size = 0
  max_size = 0
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.launch_template.public_subnets

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
}