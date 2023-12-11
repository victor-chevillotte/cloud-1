


data "cloudinit_config" "config" {
  count         = var.instance_count
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
            WORDPRESS_SUBDOMAIN = var.wordpress_sub_domain_list[count.index]
            RDS_HOST      = aws_db_instance.cloud1[count.index].address
            DOMAIN_NAME   = var.domain_name
            RDS_USER      = var.db_username
            RDS_PASSWORD  = var.db_password
            RDS_DB_NAME   = var.db_name
            PHPMYADMIN_SUBDOMAIN = var.phpmyadmin_sub_domain_list[count.index]
          })
        }
      ]
    })
  }

  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/config/userdata.sh")
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

resource "aws_instance" "wordpress" {
  count                       = var.instance_count
  ami                         = data.aws_ami.linux.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2-key-pair.key_name
  user_data_base64            = data.cloudinit_config.config[count.index].rendered
  user_data_replace_on_change = true
  security_groups             = [aws_security_group.dev-ec2.name]
  tags = {
    Name = "wordpress Instance"
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
  }

  ingress {
    description      = "Worpress"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    security_groups      = [aws_security_group.alb_sg.id]
  }

  ingress {
    description      = "PHPMyAdmin"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    security_groups      = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

