## Creating internet-facing ALB for frontend servers
resource "aws_lb" "frontend_alb" {
  name               = "frontend-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet[0].id]
  
  tags = {
    Name = "frontend-alb"
  }
}

## Creating the SG for front-end resources
resource "aws_security_group" "frontend_sg" {
  name_prefix = "frontend-sg"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Creating ASG,LC,TG and Scaling policies for front-end
resource "aws_autoscaling_group" "frontend_asg" {
  name                 = "frontend-asg"
  vpc_zone_identifier  = [aws_subnet.public_subnet[0].id]
  desired_capacity     = 2
  max_size             = 4
  min_size             = 2
  health_check_grace_period = 300
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.frontend_lc.name
  target_group_arns    = [aws_lb_target_group.frontend_tg.arn]
  
  tags = [
    {
      key                 = "Name"
      value               = "frontend-asg"
      propagate_at_launch = true
    },
  ]
}


resource "aws_autoscaling_policy" "frontend_scale_up" {
  name                   = "frontend_cpu_scale_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.frontend_asg.name

  metric_aggregation_type = "Average"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
}
resource "aws_autoscaling_policy" "frontend_scale_down" {
  name                   = "frontend_cpu_scale_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.frontend_asg.name

  metric_aggregation_type = "Average"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 30.0
  }
}

resource "aws_launch_configuration" "frontend_lc" {
  name_prefix             = "frontend-lc"
  image_id                = "ami-nsqiuhc"
  instance_type           = "t2.micro"
  security_groups         = [aws_security_group.frontend_sg.id]
  key_name                = "challenge-key"
  associate_public_ip_address = true
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "frontend_tg" {
  name        = "frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"
  
  health_check {
    enabled             = true
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    path                = "/"
  }
  
  tags = {
    Name = "frontend-tg"
  }
}


## Creating ALB for beck-end servers
resource "aws_lb" "backend_alb" {
  name               = "backend-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = [aws_subnet.private_subnet[0].id]
  
  tags = {
    Name = "backend-alb"
  }
}

## Creating the SG for back-end servers
resource "aws_security_group" "backend_sg" {
  name_prefix = "backend-sg"
  
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Creating the ASG,LC,TG and scaling policies 
resource "aws_autoscaling_group" "backend_asg" {
  name                 = "backend-asg"
  vpc_zone_identifier  = [aws_subnet.private_subnet[0].id]
  desired_capacity     = 2
  max_size             = 4
  min_size             = 2
  health_check_grace_period = 300
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.backend_lc.name
  target_group_arns    = [aws_lb_target_group.backend_tg.arn]
  
  tags = [
    {
      key                 = "Name"
      value               = "backend-asg"
      propagate_at_launch = true
    },
  ]
}

resource "aws_autoscaling_policy" "backend_scale_up" {
  name                   = "backend_scale_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.backend_asg.name
  metric_aggregation_type = "Average"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
}
resource "aws_autoscaling_policy" "backend_scale_down" {
  name                   = "backend_scale_up"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.backend_asg.name
  metric_aggregation_type = "Average"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 30.0
  }
}

resource "aws_launch_configuration" "backend_lc" {
  name_prefix             = "backend-lc"
  image_id                = "ami-yugwdyuc"
  instance_type           = "t2.micro"
  security_groups         = [aws_security_group.backend_sg.id]
  key_name                = "challenge-key"
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "backend_tg" {
  name        = "backend-tg"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id
  target_type = "instance"
  
  health_check {
    enabled             = true
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    path                = "/"
  }
  
  tags = {
    Name = "backend-tg"
  }
}


## Creating rules so that front-end servers can communicate with the backend servers
resource "aws_security_group_rule" "frontend_to_external_alb" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  security_group_id = aws_security_group.frontend_sg.id
  source_security_group_id = aws_lb.frontend_alb.security_groups[0]
}

resource "aws_security_group_rule" "backend_to_internal_alb" {
  type        = "ingress"
  from_port   = 8081
  to_port     = 8081
  protocol    = "tcp"
  security_group_id = aws_security_group.backend_sg.id
  source_security_group_id = aws_lb.backend_alb.security_groups[0]
}



