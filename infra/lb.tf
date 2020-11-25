resource "aws_lb" "alb" {
  name               = "${var.APP}-${var.ENV}-alb"
  subnets            = data.aws_subnet_ids.vpc-subnets.ids
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow-http-to-lb.id]

  tags = {
    App = var.APP
  }
}

resource "aws_lb_listener" "http-forward" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}

resource "aws_lb_target_group" "target-group" {
  name        = "${var.APP}-${var.ENV}-target-group"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ecs-main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "20"
    path                = "/"
    unhealthy_threshold = "2"
  }

  stickiness {
    type = "lb_cookie"
  }

  tags = {
    App = var.APP
  }
}
