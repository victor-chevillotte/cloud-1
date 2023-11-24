output "instances_ip" {
  value = aws_instance.wordpress[*].public_ip
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.wordpress.domain_name
}