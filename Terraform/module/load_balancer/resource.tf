resource "aws_lb" "main" {
  name                       = "ssm-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.security_group_id]
  subnets                    = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "KTB SSM load balancer"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80                              // 클라이언트가 LB에 접근하는 포트(클라이언트->LB)
  protocol          = "HTTP"

  default_action {
    type            = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = {
    Name = "KTB SSM HTTP listner"
  }
}

resource "aws_lb_target_group" "main" {
  name                  = "main-tg"
  port                  = 80                   // LB가 타겟으로 트래픽을 전달하는 포트(ALB->target(instance))
  protocol              = "HTTP"
  vpc_id                = var.vpc_id
  
  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "KTB SSM target group"
  }
}

resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = var.node_id
}
