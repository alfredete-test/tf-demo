#security group por defecto para permitir entrada por el puerto 80
resource "aws_security_group" "allow_http_and_ssh_asg" {
  name        = "allow_http_and_ssh_asg"
  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]

    security_groups = [aws_security_group.lb_sg.id]
  }

  /*
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  */


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "HTTP"# and SSH"
  }
}

#launch configuration, utilizando ubuntu
resource "aws_launch_configuration" "back_launch_config" {
  name_prefix = "server-"

  image_id = "ami-0e8f77705e947bcda"
  instance_type = "t2.micro"

  security_groups = [ aws_security_group.allow_http_and_ssh_asg.id ]
  associate_public_ip_address = false

  #insertamos el user_data desde la variable de forma que se pueda modificar para diferentes propósitos
  user_data = <<USER_DATA
#!/bin/bash
apt-get update
apt-get install -y apache2
systemctl start apache2
chmod 777 /var/www/html -R
echo "$(curl http://169.254.169.254/latest/meta-data/local-ipv4)" > /var/www/html/index.html
systemctl apache2 reload
  USER_DATA
          /*
  <<USER_DATA
#!/bin/bash
yum update
yum -y install nginx
echo "$(curl http://169.254.169.254/latest/meta-data/local-ipv4)" > /usr/share/nginx/html/index.html
chkconfig nginx on
service nginx start
  USER_DATA
  */

  #lo desactivo para la demo, además no es accesible
  key_name = aws_key_pair.from_local.key_name

  #se crea una nueva instancia antes de destruir una anterior
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "business" {
  name = "${aws_launch_configuration.back_launch_config.name}-asg"

  min_size             = 2
  desired_capacity     = 2
  max_size             = 4

  health_check_type    = "ELB"
  launch_configuration = aws_launch_configuration.back_launch_config.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier  = [
    aws_subnet.private_subnet_1a.id,aws_subnet.private_subnet_1b.id
  ]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "ec2-server"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_policy" "back_policy_up" {
  name = "back_policy_up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.business.name
}

resource "aws_cloudwatch_metric_alarm" "back_cpu_alarm_up" {
  alarm_name = "back_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.business.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions = [ aws_autoscaling_policy.back_policy_up.arn ]
}

resource "aws_autoscaling_policy" "back_policy_down" {
  name = "back_policy_down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.business.name
}

resource "aws_cloudwatch_metric_alarm" "back_cpu_alarm_down" {
  alarm_name = "back_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.business.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions = [ aws_autoscaling_policy.back_policy_down.arn ]
}

