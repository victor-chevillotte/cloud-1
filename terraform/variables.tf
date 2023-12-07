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

variable "wordpress_sub_domain_name" {
  description = "Wordpress Sub Domain Name"
}

variable "phpmyadmin_sub_domain_name" {
  description = "PhpMyAdmin Sub Domain Name"
}

variable "asg_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group. (Changing this forces a new resource to be created.)"
  default     = 2
}

variable "asg_max_size" {
  description = "The maximum size of the auto scale group. (Changing this forces a new resource to be created.)"
  default     = 4
}

variable "asg_min_size" {
  description = "The minimum size of the auto scale group. (Changing this forces a new resource to be created.)"
  default     = 1
}
