output "aws_security_group_allow_http_and_ssh_asg" {
  value = aws_security_group.allow_http_and_ssh_asg.id
}


output "lb_information" {
  value = aws_lb.load_balancer.id
}

output "lb_dns" {
  value = aws_lb.load_balancer.dns_name
}
