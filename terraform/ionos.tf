provider "ionoscloud" {
  # Vos identifiants et configurations IONOS Cloud
  username = var.ionoscloud_username
  password = var.ionoscloud_password
}

resource "ionoscloud_dns_record" "cloudfront_cname" {
  # Remplacez par l'ID de votre zone DNS
  dns_zone_id = var.ionoscloud_dns_zone_id

  # Nom de domaine pour le CNAME
  name = "www" # ou le sous-domaine de votre choix
  type = "CNAME"
  content = aws.cloudfront_distribution.wordpress.domain_name
  ttl = 3600
}

resource "ionoscloud_dns_record" "alb_cname" {
  # Remplacez par l'ID de votre zone DNS
  dns_zone_id = var.ionoscloud_dns_zone_id

  # Nom de domaine pour le CNAME
  name = "alb" # ou le sous-domaine de votre choix
  type = "CNAME"
  content = aws.lb.alb_wordpress.dns_name
  ttl = 3600
}