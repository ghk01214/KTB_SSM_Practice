output "endpoint" {
  description = "DNS name of the ALB"
  value = aws_lb.main.dns_name
}