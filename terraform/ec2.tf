

data "cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = yamlencode({
      write_files = [
        {
          path        = "/etc/systemd/system/wordpress.service"
          permissions = "0644"
          owner       = "root:root"
          content     = file("${path.module}/config/wordpress.service")
        },
        {
          path        = "/tmp/docker-compose.yaml"
          permissions = "0644"
          owner       = "root:root"
          content     = file("${path.module}/../app/docker-compose.yaml")
        },
        {
          path        = "/tmp/.env"
          permissions = "0644"
          owner       = "root:root"
          content = templatefile("${path.module}/../app/.env", {
            WORDPRESS_URL        = "${var.wordpress_sub_domain_list}.${var.domain_name}"
            RDS_HOST             = aws_db_instance.cloud1.address
            RDS_USER             = var.db_username
            RDS_PASSWORD         = var.db_password
            RDS_DB_NAME          = var.db_name
            DOMAIN_NAME          = var.domain_name
            PHPMYADMIN_SUBDOMAIN = var.phpmyadmin_sub_domain_list
            WORDPRESS_SUBDOMAIN  = var.wordpress_sub_domain_list
            EFSPATH              = aws_efs_file_system.wordpress_efs.id
          })
        }
      ]
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/config/userdata.sh", {
      EFS_DNS = aws_efs_file_system.wordpress_efs.dns_name
    })
  }
}

data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}


resource "aws_key_pair" "ec2-key-pair" {
  key_name   = "ec2-wordpress-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ec2-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "ec2-wordpress-key-pair"
}

resource "aws_security_group" "dev-ec2" {
  name        = "${var.prefix}-ec2-${var.target_group_name}"
  description = "rules for wordpress-ec2"

  ingress {
    description = "EFS mount target"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH Access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Worpress"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "PHPMyAdmin"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


# Launch Configuration
# resource "aws_launch_configuration" "wordpress_lc" {
#   depends_on    = [aws_db_instance.cloud1]
#   name_prefix   = "wordpress-lc-"
#   image_id      = data.aws_ami.linux.id
#   instance_type = var.instance_type
#   key_name      = aws_key_pair.ec2-key-pair.key_name

#   security_groups = [aws_security_group.dev-ec2.id]

#   user_data_base64            = data.cloudinit_config.config.rendered
#   associate_public_ip_address = true

#   lifecycle {
#     create_before_destroy = true
#   }
# }

resource "aws_launch_template" "wordpress_lt" {
  name_prefix   = "wordpress-lt-"
  image_id      = data.aws_ami.linux.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ec2-key-pair.key_name

  user_data = base64encode(data.cloudinit_config.config.rendered)

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.dev-ec2.id]
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_db_instance.cloud1]
}
