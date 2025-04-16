resource "aws_lb" "alb" {
  name               = "my-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public.id]
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_lb_target_group" "nlb_tg" {
  name        = "nlb-to-alb"
  port        = 80
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "alb_to_nlb" {
  target_group_arn = aws_lb_target_group.nlb_tg.arn
  target_id        = aws_lb.alb.dns_name  
  port             = 80
}

resource "aws_lb" "nlb" {
  name               = "my-nlb"
  load_balancer_type = "network"
  subnets            = [aws_subnet.public.id]
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg.arn
  }
}