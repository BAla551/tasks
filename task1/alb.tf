
resource "aws_lb" "wp_alb" {
  name               = "wp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.wp_alb_tf.id]
  subnets            = [aws_subnet.wp_public_a_tf.id, aws_subnet.wp_public_b_tf.id]
}

resource "aws_lb_target_group" "default" {
  name        = "wp-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.wp_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}

resource "aws_ecs_service" "wp_ecs_svc" {
  name            = "wp-ecs-svc"
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.wordpress.arn
  desired_count   = 1
  scheduling_strategy = "REPLICA"

  capacity_provider_strategy {
    capacity_provider = "EC2"
    weight            = 1
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.default.arn
    container_name   = "wordpress"
    container_port   = 80
  }
}