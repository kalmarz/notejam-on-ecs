resource "aws_ecs_service" "notejam-ecs-svc" {
  name             = "${var.APP}-${var.ENV}-ecs-svc"
  cluster          = aws_ecs_cluster.cluster.id
  task_definition  = aws_ecs_task_definition.notejam.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    security_groups  = [aws_vpc.ecs-main.default_security_group_id]
    subnets          = data.aws_subnet_ids.vpc-subnets.ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target-group.arn
    container_name   = var.APP
    container_port   = var.CONTAINER_PORT
  }

  depends_on = [aws_lb_listener.http-forward, aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment]

  tags = {
    App = var.APP
  }
}
