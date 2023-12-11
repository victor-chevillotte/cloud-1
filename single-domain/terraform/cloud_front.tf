resource "aws_cloudfront_distribution" "cloud1" {
  provider = aws.us-east-1
  aliases  = ["${var.wordpress_sub_domain_name}.${var.domain_name}", "${var.phpmyadmin_sub_domain_name}.${var.domain_name}"]
  origin {
    domain_name = aws_lb.alb_wordpress.dns_name
    origin_id   = aws_lb.alb_wordpress.id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }


  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    cache_policy_id  = aws_cloudfront_cache_policy.cloud1.id
    target_origin_id = aws_lb.alb_wordpress.id

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    viewer_protocol_policy   = "redirect-to-https"
    origin_request_policy_id = aws_cloudfront_origin_request_policy.cloud1.id

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    iam_certificate_id       = aws_iam_server_certificate.cloud1_cert.id
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}

resource "aws_iam_server_certificate" "cloud1_cert" {
  provider          = aws.us-east-1
  path              = "/cloudfront/test/"
  name              = "${var.prefix}-cert"
  certificate_body  = file("${path.module}/ssl/mdesoeuv.com_ssl_certificate.cer")
  certificate_chain = file("${path.module}/ssl/mdesoeuv.com_ssl_certificate_INTERMEDIATE.cer")
  private_key       = file("${path.module}/ssl/mdesoeuv.com_private_key.key")
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_cloudfront_origin_request_policy" "cloud1" {
  name = "${var.prefix}-policy"

  cookies_config {
    cookie_behavior = "all"
  }
  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Host"]
    }
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}

resource "aws_cloudfront_cache_policy" "cloud1" {
  name = "${var.prefix}-cache-policy"

  default_ttl = 10
  max_ttl     = 20
  min_ttl     = 1

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "all"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Host"]
      }
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}
