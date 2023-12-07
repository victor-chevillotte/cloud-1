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
  type = number
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

variable "wordpress_sub_domain_list" {
  description = "Wordpress Sub Domain Name"
}

variable "phpmyadmin_sub_domain_list" {
  description = "PhpMyAdmin Sub Domain Name"
}

variable "desired_instances" {
  description = "The number of Amazon EC2 instances that should be running in the group. (Changing this forces a new resource to be created.)"
  default     = 3
}

variable "wordpress_sub_domain_list" {
  description = "Wordpress Sub Domain Name list"
  type        = list(string)
  default     = ["wp1", "wp2", "wp3"]
}
variable "phpmyadmin_sub_domain_list" {
  description = "PhpMyAdmin Sub Domain Name list"
  type        = list(string)
  default     = ["pma1", "pma2", "pma3"]
}
