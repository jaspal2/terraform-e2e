
resource "aws_launch_template" "terraform_template" {
  name = "terrafomr_template"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }
  image_id = data.aws_ami.ubuntu_ami.id

  vpc_security_group_ids = [module.web_server_sg.security_group_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }

}
