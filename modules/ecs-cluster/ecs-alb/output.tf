output "alb_an" {
  value = aws_lb.alb.arn
}

output "alb_back_tg" {
  value = aws_lb_target_group.backend.arn
}

output "alb_front_tg" {
  value = aws_lb_target_group.frontend.arn
}