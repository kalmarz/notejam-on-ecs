resource "aws_security_group_rule" "allow-access-from-lb" {
  type                     = "ingress"
  from_port                = var.CONTAINER_PORT
  to_port                  = var.CONTAINER_PORT
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.allow-http-to-lb.id
  security_group_id        = aws_vpc.ecs-main.default_security_group_id
}

resource "aws_security_group" "allow-http-to-lb" {
  name   = "${var.APP}-${var.ENV}-lb"
  vpc_id = aws_vpc.ecs-main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.APP}-${var.ENV}-lb-sg"
    App  = var.APP
  }
}
