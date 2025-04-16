resource "aws_lb_target_group" "nlb_tg" {
  name        = "nlb-to-alb"
  port        = 80
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
}