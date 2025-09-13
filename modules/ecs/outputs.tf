output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the application load balancer"
  value       = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "ARN of the application load balancer"
  value       = aws_lb.main.arn
}

output "app_service_name" {
  description = "Name of the app ECS service"
  value       = aws_ecs_service.app.name
}

output "app_service_arn" {
  description = "ARN of the app ECS service"
  value       = aws_ecs_service.app.id
}

output "mongo_service_name" {
  description = "Name of the MongoDB ECS service"
  value       = aws_ecs_service.mongo.name
}

output "mongo_service_arn" {
  description = "ARN of the MongoDB ECS service"
  value       = aws_ecs_service.mongo.id
}

output "app_task_definition_arn" {
  description = "ARN of the app task definition"
  value       = aws_ecs_task_definition.app.arn
}

output "mongo_task_definition_arn" {
  description = "ARN of the MongoDB task definition"
  value       = aws_ecs_task_definition.mongo.arn
}

output "app_security_group_id" {
  description = "ID of the app security group"
  value       = aws_security_group.app.id
}

output "mongo_security_group_id" {
  description = "ID of the MongoDB security group"
  value       = aws_security_group.mongo.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}