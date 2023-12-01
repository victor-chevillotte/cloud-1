output "instances_ip" {
  value = aws_instance.wordpress[*].public_ip
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.wordpress.domain_name
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.wordpress.viewer_certificate[0].acm_certificate_arn
}