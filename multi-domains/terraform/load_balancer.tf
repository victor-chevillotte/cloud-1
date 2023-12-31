data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_lb" "alb_wordpress" {
  name               = "${var.prefix}-${var.alb_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids
}



resource "aws_lb_target_group" "tg_wordpress" {
  count    = var.instance_count
  name     = "${var.prefix}-${var.target_group_name}-${count.index}-${substr(uuid(), 0, 3)}"
  port     = 8080 #port of wordpress
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }

  health_check {
    enabled             = true
    path                = "/wp-admin/images/wordpress-logo.svg"
    port                = 8080
    interval            = 25
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 4
    matcher             = "200,201"
  }

  stickiness {
    enabled = true
    type    = "lb_cookie"
  }

}


resource "aws_lb_target_group" "tg_phpmyadmin" {
  count    = var.instance_count
  name     = "${var.prefix}-phpmyadmin-${count.index}-${substr(uuid(), 0, 3)}"
  port     = 8081 #port of phpmyadmin
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }

  health_check {
    enabled             = true
    interval            = 25
    healthy_threshold   = 2
    unhealthy_threshold = 2
    path                = "/"
    port                = 8081
    timeout             = 4
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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

resource "aws_lb_listener_rule" "wordpress" {
  count        = var.instance_count
  listener_arn = aws_lb_listener.https.arn
  priority     = 80 + count.index

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_wordpress[count.index].arn
  }

  condition {
    host_header {
      values = ["${var.wordpress_sub_domain_list[count.index]}.${var.domain_name}"]
    }
  }
}

resource "aws_lb_listener_rule" "phpmyadmin" {
  count        = var.instance_count
  listener_arn = aws_lb_listener.https.arn
  priority     = 100 + count.index

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_phpmyadmin[count.index].arn
  }

  condition {
    host_header {
      values = ["${var.phpmyadmin_sub_domain_list[count.index]}.${var.domain_name}"]
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
    target_group_arn = aws_lb_target_group.tg_wordpress[0].arn
    forward {
      target_group {
        arn = aws_lb_target_group.tg_wordpress[0].arn
      }

      stickiness {
        enabled  = true
        duration = 86400
      }
    }
  }

}

resource "aws_lb_target_group_attachment" "wordpress" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.tg_wordpress[count.index].arn
  target_id        = aws_instance.wordpress[count.index].id
  port             = 8080
}


resource "aws_lb_target_group_attachment" "phpmyadmin" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.tg_phpmyadmin[count.index].arn
  target_id        = aws_instance.wordpress[count.index].id
  port             = 8081
}
