provider "ionosdeveloper" {
  api_key = var.ionoscloud_token
}

data "ionosdeveloper_dns_zone" "example" {
  name = var.domain_name
}

resource "ionosdeveloper_dns_record" "cloudfront_cname" {
  zone_id = data.ionosdeveloper_dns_zone.example.id

  name    = "${var.wordpress_sub_domain_name}.${var.domain_name}"
  type    = "CNAME"
  content = aws_cloudfront_distribution.cloud1.domain_name
  ttl     = 3600
}

resource "ionosdeveloper_dns_record" "phpmyadmin_cname" {
  zone_id = data.ionosdeveloper_dns_zone.example.id

  name    = "${var.phpmyadmin_sub_domain_name}.${var.domain_name}"
  type    = "CNAME"
  content = aws_cloudfront_distribution.cloud1.domain_name
  ttl     = 3600
}
