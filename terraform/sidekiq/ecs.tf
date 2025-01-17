# ###
# Set up the cluster
# ###
resource "aws_ecs_cluster" "sidekiq" {
  name = "sidekiq"
}
data "template_file" "sidekiq" {
  template = file("./sidekiq/ecs_task_definition.json.tpl")

  vars = {
    rails_image        = "${var.aws_ecr_repository_webserver_rails.repository_url}:latest"
    region             = var.region
    log_group_name     = aws_cloudwatch_log_group.sidekiq.name
  }
}
resource "aws_ecs_task_definition" "sidekiq" {
  family                   = "sidekiq"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  container_definitions    = data.template_file.sidekiq.rendered
  execution_role_arn       = var.aws_iam_role_ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs.arn
  tags                     = {}

  volume {
    name = "efs-repositories"
    efs_volume_configuration {
      file_system_id = var.aws_efs_file_system_repositories.id
    }
  }

  volume {
    name = "efs-tooling-jobs"
    efs_volume_configuration {
      file_system_id = var.aws_efs_file_system_tooling_jobs.id
    }
  }
}

resource "aws_ecs_service" "sidekiq" {
  name             = "sidekiq"
  cluster          = aws_ecs_cluster.sidekiq.id
  task_definition  = aws_ecs_task_definition.sidekiq.arn
  desired_count    = var.container_count
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    security_groups = [
      aws_security_group.ecs.id,
      var.aws_security_group_efs_repositories_access.id,
      var.aws_security_group_efs_tooling_jobs_access.id
    ]
    subnets = var.aws_subnet_publics.*.id

    # TODO: Can this be false?
    assign_public_ip = true
  }
}

