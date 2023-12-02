provider "ionosdeveloper" {
    api_key = var.ionoscloud_token
}

data "ionosdeveloper_dns_zone" "example" {
  name = var.domain_name
}

resource "ionosdeveloper_dns_record" "cloudfront_cname" {
  zone_id = data.ionosdeveloper_dns_zone.example.id

  name    = "cloud1.mdesoeuv.com"
  type    = "CNAME"
  content = aws_cloudfront_distribution.wordpress.domain_name
  ttl     = 3600
}

# resource "ionosdeveloper_dns_record" "alb_cname" {
#   zone_id = data.ionosdeveloper_dns_zone.example.id

#   name    = "alb"
#   type    = "CNAME"
#   content = aws_lb.alb_wordpress.dns_name
#   ttl     = 3600
# }