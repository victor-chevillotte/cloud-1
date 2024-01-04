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
  description = "Number of instances to create (Max 5)"

  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 5
    error_message = "Number of instances must be at leat 1 and less than 6"
  }
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
  description = "Wordpress Sub Domain Name list"
  type        = list(string)
  default     = ["wp1", "wp2", "wp3", "wp4", "wp5"]
}
variable "phpmyadmin_sub_domain_list" {
  description = "PhpMyAdmin Sub Domain Name list"
  type        = list(string)
  default     = ["pma1", "pma2", "pma3", "pma4", "pma5"]
}
