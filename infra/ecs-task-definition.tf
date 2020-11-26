module "notejam-container" {
  source          = "./modules/terraform-aws-ecs-container-definition-0.45.2/"
  container_name  = var.APP
  container_image = "${aws_ecr_repository.notejam.repository_url}:latest"
  port_mappings = [
    {
      containerPort = var.CONTAINER_PORT
      hostPort      = var.CONTAINER_PORT
      protocol      = "tcp"
  }]
  mount_points = [
    {
      containerPath = var.CONTAINER_PATH
      sourceVolume  = aws_efs_file_system.notejam.creation_token
  }]
  log_configuration = {
    "logDriver" = "awslogs"
    "options" = {
      "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
      "awslogs-region"        = var.AWS_REGION
      "awslogs-stream-prefix" = "ecs"
    }
  }
}

resource "aws_ecs_task_definition" "notejam" {
  family                   = "${var.APP}-${var.ENV}"
  container_definitions    = "[${module.notejam-container.json_map_encoded}]"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.TASK_CPU
  memory                   = var.TASK_MEMORY
  execution_role_arn       = aws_iam_role.ecs-task-execution-role.arn

  volume {
    name = aws_efs_file_system.notejam.creation_token
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.notejam.id
      transit_encryption = "ENABLED"
    }
  }

}
