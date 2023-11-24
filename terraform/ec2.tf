

data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "dev" {
  ami                         = data.aws_ami.linux.id
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2-key-pair.key_name
  user_data_base64            = filebase64("${path.module}/config/userdata.sh")
  user_data_replace_on_change = true
  security_groups             = [aws_security_group.dev-ec2.name]
  tags = {
    Name = "Dev Instance"
  }
}

resource "aws_key_pair" "ec2-key-pair" {
  key_name   = "ec2-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ec2-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "ec2-key-pair"
}

resource "aws_security_group" "dev-ec2" {
  name        = "dev-ec2-sg"
  description = "rules for dev-ec2"

  ingress {
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
    from_port        = 8080
    to_port          = 8080
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
