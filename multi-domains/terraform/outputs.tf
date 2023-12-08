output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.cloud1.domain_name
}

output "alb_dns_name" {
  value = aws_lb.alb_wordpress.dns_name
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.cloud1.id
}

output "instance_public_ip" {
  value = aws_instance.wordpress.*.public_ip
}