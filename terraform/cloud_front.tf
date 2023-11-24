resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_lb.alb_wordpress.dns_name
    origin_id   = aws_lb.alb_wordpress.id

  }

  enabled             = true
  is_ipv6_enabled     = true

  default_cache_behavior {
	cached_methods 
	viewer_protocol_policy = "allow-all"
    cache_policy_id  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

}