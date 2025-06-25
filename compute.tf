# Find the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "EC2-SSM-Instance-Profile"
  role = "EC2-SSM-Role" # This MUST match the name of the role you created in Step 1
}


resource "aws_launch_template" "web_server" {
  name_prefix   = "web-server-template-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  user_data     = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
  )
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # ADD THIS BLOCK
  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_instance_profile.name
  }

  tags = {
    Name = "WebServer-Launch-Template"
  }
}





# Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  name                = "web-server-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = [for subnet in aws_subnet.private : subnet.id]

  launch_template {
    id      = aws_launch_template.web_server.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.main.id]

  tag {
    key                 = "Name"
    value               = "WebServer-Instance"
    propagate_at_launch = true
  }
}


