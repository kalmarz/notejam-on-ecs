resource "aws_ecs_cluster" "cluster" {
  name = "${var.APP}-${var.ENV}-ecs-cluster"

  tags = {
    Name = "${var.APP}-${var.ENV}-ecs-cluster"
    App  = var.APP
  }
}
