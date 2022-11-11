resource "aws_security_group" "jungle-meet-alb" {
  name        = "jungle-meet-alb"
  description = "Allow HTTP from internet"
  vpc_id      = aws_vpc.jungle-meet.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.jungle-meet-ecs-task.id]
  }
}

resource "aws_security_group" "jungle-meet-ecs-task" {
  name   = "allow-connection-to-containers"
  vpc_id = aws_vpc.jungle-meet.id

  ingress {
    protocol         = "tcp"
    from_port        = var.host_port
    to_port          = var.container_port
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}