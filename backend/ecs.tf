resource "aws_ecr_repository" "jungle-meet-backend" {
  name                 = "jungle-meet-backend"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "jungle-meet-backend" {
  name = "jungle-meet-backend"
}

resource "aws_ecs_task_definition" "jungle-meet-backend" {
  family                = "jungle-meet-backend-task-definition"
  network_mode          ="awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
    name      = "jungle-meet-backend"
    image     = "${aws_ecr_repository.jungle-meet-backend.repository_url}:latest"
    essential = true
    //environment = var.container_environment
    portMappings = [{
      protocol      = "HTTP"
      containerPort = var.container_port
      hostPort      = var.host_port
    }]
  }])
}

resource "aws_ecs_service" "jungle-meet-backend" {
  name                               = "jungle-meet-backend-ecs-servicce"
  cluster                            = aws_ecs_cluster.jungle-meet-backend.id
  task_definition                    = aws_ecs_task_definition.jungle-meet-backend.arn
  desired_count                      = 2
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups = [aws_security_group.jungle-meet-ecs-task.id]
    subnets         = [aws_subnet.jungle-meet-be-private-01.id,
                       aws_subnet.jungle-meet-be-private-02.id]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.jungle-meet.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}
