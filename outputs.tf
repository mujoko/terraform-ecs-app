output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs.cluster_id
}

output "app_load_balancer_dns" {
  description = "DNS name of the application load balancer"
  value       = module.ecs.alb_dns_name
}

output "app_load_balancer_zone_id" {
  description = "Zone ID of the application load balancer"
  value       = module.ecs.alb_zone_id
}

output "app_service_arn" {
  description = "ARN of the app ECS service"
  value       = module.ecs.app_service_arn
}

output "mongo_service_arn" {
  description = "ARN of the MongoDB ECS service"
  value       = module.ecs.mongo_service_arn
}