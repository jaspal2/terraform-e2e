module "launch_template" {
  source = "./launch-template"
}


module "create_ASG" {
  source = "./terraform-aws-autoscaling-master/terraform-aws-autoscaling-master/"
  name = "Terrafomr_asg"
  create_launch_template = false
  launch_template_id        = module.launch_template.launch_template_id
  min_size = 1
  max_size = 2
  desired_capacity          = 2
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




module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "alb-terraform"
  vpc_id  = module.launch_template.vpc_id

  create_security_group = false
  security_groups       = module.launch_template.security_group_id
  subnets               = module.launch_template.public_subnets 

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

      forward = {
        target_group_key = "ex-instance"
      }
    }
  }

  target_groups = {
    ex-instance = {
      name_prefix      = "h1"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
    }
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}


resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = module.create_ASG.autoscaling_group_name
  lb_target_group_arn    = module.alb.target_groups["ex-instance"].arn
}