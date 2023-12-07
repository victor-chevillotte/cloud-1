data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
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

  health_check {
    enabled             = true
    path                = "/"
    port                = 8080
    interval            = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200,201,301,302"
  }

  stickiness {
    enabled = true
    type    = "lb_cookie"
  }

}


resource "aws_lb_target_group" "tg_phpmyadmin" {
  name     = "${var.prefix}-phpmyadmin-${substr(uuid(), 0, 3)}"
  port     = 8081 #port of phpmyadmin
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }

  health_check {
    enabled             = true
    interval            = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    path                = "/"
    port                = 8081
    matcher             = "200,201,301,302"
  }


  stickiness {
    enabled = true
    type    = "lb_cookie"
  }

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

resource "aws_autoscaling_attachment" "wordpress_attachment" {
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.id
  lb_target_group_arn    = aws_lb_target_group.tg_wordpress.arn
}

resource "aws_autoscaling_attachment" "phpmyadmin_attachment" {
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.id
  lb_target_group_arn    = aws_lb_target_group.tg_phpmyadmin.arn
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
    host_header {
      values = ["${var.phpmyadmin_sub_domain_name}.${var.domain_name}"]
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb_wordpress.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_iam_server_certificate.cloud1_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_wordpress.arn
    forward {
      target_group {
        arn = aws_lb_target_group.tg_wordpress.arn
      }

      stickiness {
        enabled  = true
        duration = 86400
      }
    }
  }

}

