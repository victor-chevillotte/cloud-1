provider "ionosdeveloper" {
  api_key = var.ionoscloud_token
}

data "ionosdeveloper_dns_zone" "example" {
  name = var.domain_name
}

resource "ionosdeveloper_dns_record" "cloudfront_cname" {
  zone_id = data.ionosdeveloper_dns_zone.example.id

  name    = "${var.sub_domain_name}.${var.domain_name}"
  type    = "CNAME"
  content = aws_cloudfront_distribution.wordpress.domain_name
  ttl     = 3600
}

resource "ionosdeveloper_dns_record" "phpmyadmin_cname" {
  zone_id = data.ionosdeveloper_dns_zone.example.id

  name    = "phpmyadmin.${var.domain_name}"
  type    = "CNAME"
  content = aws_cloudfront_distribution.wordpress.domain_name
  ttl     = 3600
}


resource "ionosdeveloper_dns_record" "traefik_cname" {
  zone_id = data.ionosdeveloper_dns_zone.example.id

  name    = "traefik.${var.domain_name}"
  type    = "CNAME"
  content = aws_cloudfront_distribution.wordpress.domain_name
  ttl     = 3600
}