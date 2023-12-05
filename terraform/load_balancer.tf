data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_lb_target_group" "tg_phpmyadmin" {
  name     = "${var.prefix}-${var.target_group_name}-${substr(uuid(), 0, 3)}"
  port     = 8081 #port of phpmyadmin
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }

  # health check is docker up ?
  # health_check {
  #   enabled = true
  #   path    = "/index.html"
  #   port    = 8080
  #   matcher = 200
  # }
}


resource "aws_lb_target_group" "tg_wordpress" {
  name     = "${var.prefix}-${var.target_group_name}-${substr(uuid(), 0, 3)}"
  port     = 8080 #port of wordpress
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }

  # health check is docker up ?
  # health_check {
  #   enabled = true
  #   path    = "/index.html"
  #   port    = 8080
  #   matcher = 200
  # }
}

resource "aws_security_group" "alb_sg" {
  name = "${var.prefix}-${var.alb_sg_name}"

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


resource "aws_lb" "alb_wordpress" {
  name               = "${var.prefix}-${var.alb_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_target_group_attachment" "wordpress_attachment" {
  depends_on       = [aws_instance.wordpress]
  count            = length(aws_instance.wordpress)
  target_group_arn = aws_lb_target_group.tg_wordpress.arn
  target_id        = aws_instance.wordpress[count.index].id
  port             = 8080
}

resource "aws_lb_listener" "redirect_https" {
  load_balancer_arn = aws_lb.alb_wordpress.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_lb_listener_rule" "phpmyadmin" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_phpmyadmin.arn
  }

  condition {
    path_pattern {
      values = ["/phpmyadmin/*"]
    }
  }
}



resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb_wordpress.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_iam_server_certificate.test_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_wordpress.arn
  }

}

