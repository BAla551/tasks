resource "aws_ecs_cluster" "default" {
    name = var.ecs_cluster_name
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/wp-ecs-tf"
  retention_in_days = 7

  tags = {
    Environment = "production"
    Application = "wp"
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_launch_template" "ecs" {
  name_prefix   = "ecs-template-"
  image_id      = "ami-06b6e5225d1db5f46"  
  instance_type = var.ecs_instance_type
  key_name      = var.key_pair_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.default.name} >> /etc/ecs/ecs.config
  EOF
  )
}

resource "aws_autoscaling_group" "ecs" {
  vpc_zone_identifier = [aws_subnet.wp-private-b-tf.id, aws_subnet.wp-private-c-tf.id]
  desired_capacity    = 2
  min_size           = 1
  max_size           = 3

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }
}

resource "aws_ecs_task_definition" "wordpress" {
  family                   = "wp-ecs-task-tf"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_instance_role.arn

  container_definitions = jsonencode([
    {
      name      = "wordpress"
      image     = "wordpress:latest"
      cpu       = 1024
      memory    = 2048
      essential = true

      environment = [
        {
          name  = "WORDPRESS_DB_HOST"
          value = aws_db_instance.db.address
        },
        {
          name  = "WORDPRESS_DB_NAME"
          value = var.db_name
        },
        {
          name  = "WORDPRESS_DB_USER"
          value = var.db_user
        },
        {
          name  = "WORDPRESS_DB_PASSWORD"
          value = var.db_password
        }
      ]

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}


resource "aws_ecs_service" "wp-ecs-sv" {
  name            = "wp-ecs-svc-tf"
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.wordpress.arn
  desired_count   = 1
  scheduling_strategy = "REPLICA"

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ec2_provider.name
    weight            = 1
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.default.arn
    container_name   = "wordpress"
    container_port   = 80
  }
}




