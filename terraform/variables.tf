variable "aws_region" {
  default = "eu-west-1"
  type    = string
}

variable "instance_type" {
  default = "t2.micro"
  type    = string
}

variable "prefix" {
  default = "c1"
  type    = string
}

variable "target_group_name" {
  default = "wordpress"
  type    = string
}

variable "target_group_port" {
  default = 8080
  type    = number
}

variable "target_group_protocol" {
  default = "TCP"
  type    = string
}

variable "alb_sg_name" {
  default = "wordpress_alb"
  type    = string
}

variable "alb_name" {
  default = "wordpress"
  type    = string
}

variable "instance_count" {
  default = 3
  type    = number
}

variable "db_name" {
  default = "wordpress"
  type    = string
}

variable "db_username" {
  default = "wordpress"
  type    = string
}


variable "db_password" {
  default = "wordpress"
  type    = string
}

variable "ionoscloud_username" {
  description = "IONOS Cloud username"
}

variable "ionoscloud_password" {
  description = "IONOS Cloud password"
}

variable "ionoscloud_dns_zone_id" {
  description = "IONOS Cloud DNS zone ID"
}