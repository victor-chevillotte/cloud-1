resource "aws_cloudfront_distribution" "wordpress" {
  origin {
    domain_name = "cloud.mdesoeuv.com"
    origin_id   = aws_lb.alb_wordpress.id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_lb.alb_wordpress.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}

provider "aws" {
  alias = "virginia"
  region = "us-east-1"
}

resource "aws_acm_certificate" "cert" {
  provider = aws.virginia
  private_key = file("${path.module}/ssl/mdesoeuv.com_private_key.key")
  certificate_body = file("${path.module}/ssl/mdesoeuv.com_ssl_certificate.cer")
  certificate_chain = file("${path.module}/ssl/mdesoeuv.com_ssl_certificate_INTERMEDIATE.cer")
  }