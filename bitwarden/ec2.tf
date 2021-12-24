# 시작 템플릿
resource "aws_launch_template" "launch_bitwarden" {
  name = "bitwarden"
  instance_type = "t2.small" # 1 Core / 2GB RAM
  image_id = "ami-0454bb2fefc7de534" # Ubuntu 20.04
  key_name = var.key_pair
  update_default_version = true

  network_interfaces {
    device_index = 0
    network_interface_id = aws_network_interface.nic_bitwarden.id
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 10 # GB
    }
  }

  credit_specification {
    cpu_credits = "standard"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.tag} Instance"
      Project = var.tag
    }
  }

  tags = {
    Name = "${var.tag} Launch Template"
    Project = var.tag
  }
}

resource "aws_instance" "ec2_bitwarden" {
  launch_template {
    id = aws_launch_template.launch_bitwarden.id
    version = aws_launch_template.launch_bitwarden.latest_version
  }
}
