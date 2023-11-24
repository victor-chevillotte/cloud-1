
output "cloudfront_domain_name" {
  value = "${aws_cloudfront_distribution.cloudfront.domain_name}"
}