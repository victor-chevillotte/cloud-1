output "instance_ip" {
  value = aws_instance.wordpress
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.wordpress.domain_name
}