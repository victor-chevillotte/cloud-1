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
  default = 2
  type    = number
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}


variable "db_password" {
  type = string
}

variable "ionoscloud_token" {
  description = "API KEY"
}

variable "domain_name" {
  description = "Domain Name"
  default     = "mdesoeuv.com"
}

variable "sub_domain_name" {
  description = "Sub Domain Name"
}