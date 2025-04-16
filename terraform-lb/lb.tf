resource "aws_lb" "alb" {
  name               = "my-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public.id, aws_subnet.private.id]
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
resource "aws_lb_target_group" "alb_tg" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
    port = "80"
  }
}
# sa ALB-a na EC2
resource "aws_lb_target_group_attachment" "web_attach" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.web.id
  port             = 80
}
#---------

resource "aws_lb" "nlb" {
  name               = "my-nlb"
  load_balancer_type = "network"
  subnets            = [aws_subnet.public.id]
  # subnet_mappings {
  #   subnet_id     = aws_subnet.public.id
  #   allocation_id = aws_eip.nlb_eip.id
  # }
}
resource "aws_lb_target_group" "nlb_tg" {
  name        = "nlb-to-alb"
  port        = 80
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
}
# sa NLB-a na ALB
resource "aws_lb_target_group_attachment" "alb_to_nlb" {
  target_group_arn = aws_lb_target_group.nlb_tg.arn
  target_id        = aws_lb.alb.dns_name  
  port             = 80
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
#------
# NLB static IP