resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/${var.APP}-${var.ENV}"

  tags = {
    App = var.APP
  }
}
