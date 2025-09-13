variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "app_image" {
  description = "ECR image URI for the application"
  type        = string
}

variable "app_container_port" {
  description = "Port that the application listens on"
  type        = number
}

variable "app_desired_count" {
  description = "Desired number of app task instances"
  type        = number
}

variable "app_cpu" {
  description = "CPU units for app container (1024 = 1 vCPU)"
  type        = number
}

variable "app_memory" {
  description = "Memory for app container in MB"
  type        = number
}

variable "mongo_image" {
  description = "MongoDB Docker image"
  type        = string
}

variable "mongo_port" {
  description = "MongoDB port"
  type        = number
}

variable "mongo_cpu" {
  description = "CPU units for MongoDB container (1024 = 1 vCPU)"
  type        = number
}

variable "mongo_memory" {
  description = "Memory for MongoDB container in MB"
  type        = number
}