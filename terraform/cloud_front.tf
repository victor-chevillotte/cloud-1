resource "aws_cloudfront_distribution" "wordpress" {
  aliases = ["cloud.mdesoeuv.com"]
  origin {
    domain_name = aws_lb.alb_wordpress.dns_name
    origin_id   = aws_lb.alb_wordpress.id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
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
    iam_certificate_id       = aws_iam_server_certificate.test_cert.id
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

resource "aws_iam_server_certificate" "test_cert" {
  provider          = aws.us-east-1
  path              = "/cloudfront/test/"
  name              = "${var.prefix}-test-cert3"
  certificate_body  = file("${path.module}/ssl/mdesoeuv.com_ssl_certificate_2.cer")
  certificate_chain = file("${path.module}/ssl/mdesoeuv.com_ssl_certificate_INTERMEDIATE_2.cer")
  private_key       = file("${path.module}/ssl/mdesoeuv.com_private_key_1.key")
  lifecycle {
    create_before_destroy = true
  }
}