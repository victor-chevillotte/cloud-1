output "instances_ip" {
  value = aws_instance.wordpress[*].public_ip
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.wordpress.domain_name
}

output "alb_dns_name" {
  value = aws_lb.alb_wordpress.dns_name
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.wordpress.id
}