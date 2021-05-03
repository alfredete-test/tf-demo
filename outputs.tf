output "lb_information" {
  value = aws_lb.load_balancer.id
}

output "lb_dns" {
  value = aws_lb.load_balancer.dns_name
}
