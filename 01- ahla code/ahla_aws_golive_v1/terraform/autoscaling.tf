resource "aws_appautoscaling_target" "chat" {
  max_capacity       = var.chat_max
  min_capacity       = var.chat_min
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.chat.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "chat_target_tracking" {
  name               = "${var.project}-chat-tt"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.chat.resource_id
  scalable_dimension = aws_appautoscaling_target.chat.scalable_dimension
  service_namespace  = aws_appautoscaling_target.chat.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 50
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
