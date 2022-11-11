resource "aws_alb" "jungle-meet" {
  name               = "jungle-meet"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.jungle-meet-alb.id]
  subnets            = [aws_subnet.jungle-meet-be-public-01.id,
                        aws_subnet.jungle-meet-be-public-02.id]

  enable_deletion_protection = false
}

resource "aws_alb_listener" "jungle-meet" {
  load_balancer_arn = aws_alb.jungle-meet.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.jungle-meet.arn
  }
}

resource "aws_alb_target_group" "jungle-meet" {
  name        = "jungle-meet"
  port        = var.host_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.jungle-meet.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    unhealthy_threshold = "2"
  }
}