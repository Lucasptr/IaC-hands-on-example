
resource "aws_launch_template" "terraform_launch_template" {
  name          = "${var.prefix}-template"
  image_id      = "ami-0e0d2e3754385cbd3"
  instance_type = "t3.micro"

  user_data = base64encode(var.user_data)

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.security_group_ids
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.prefix}-node"
    }
  }
}

resource "aws_autoscaling_group" "terraform_asg" {
  name                = "${var.prefix}-asg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [aws_lb_target_group.terraform_lb_target_group.arn]

  launch_template {
    id      = aws_launch_template.terraform_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.prefix}-node"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "terraform_scale_out_policy" {
  name                   = "${var.prefix}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.terraform_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.scale_out.scaling_adjustment
  cooldown               = var.scale_out.cooldown
}

resource "aws_cloudwatch_metric_alarm" "terraform_scale_out_alarm" {
  alarm_name          = "${var.prefix}-scale-out-alarm"
  alarm_description   = "Alarm when CPU exceeds 60%"
  alarm_actions       = [aws_autoscaling_policy.terraform_scale_out_policy.arn]
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.scale_out.threshold
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  evaluation_periods  = 2   // This means that the alarm will trigger if the CPU utilization exceeds 60% for 2 consecutive periods.
  period              = 120 // This means that each evaluation period is 120 seconds (2 minutes).

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.terraform_asg.name
  }
}


resource "aws_autoscaling_policy" "terraform_scale_in_policy" {
  name                   = "${var.prefix}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.terraform_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.scale_in.scaling_adjustment
  cooldown               = var.scale_in.cooldown
}

resource "aws_cloudwatch_metric_alarm" "terraform_scale_in_alarm" {
  alarm_name          = "${var.prefix}-scale-in-alarm"
  alarm_description   = "Alarm when CPU exceeds 60%"
  alarm_actions       = [aws_autoscaling_policy.terraform_scale_in_policy.arn]
  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = var.scale_in.threshold
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  evaluation_periods  = 2   // This means that the alarm will trigger if the CPU utilization is below 20% for 2 consecutive periods.
  period              = 120 // This means that each evaluation period is 120 seconds (2 minutes).

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.terraform_asg.name
  }
}

resource "aws_lb" "terraform_lb" {
  name                       = "${var.prefix}-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = var.security_group_ids
  subnets                    = var.subnet_ids
  enable_deletion_protection = false

  tags = {
    Name = "${var.prefix}-terraform-lb"
  }
}

resource "aws_lb_target_group" "terraform_lb_target_group" {
  name     = "${var.prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "${var.prefix}-terraform-tg"
  }
}

resource "aws_lb_listener" "terraform_lb_listener" {
  load_balancer_arn = aws_lb.terraform_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terraform_lb_target_group.arn
  }
}
