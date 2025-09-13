variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "expresscart"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app_image" {
  description = "ECR image URI for the application"
  type        = string
}

variable "app_container_port" {
  description = "Port that the application listens on"
  type        = number
  default     = 8080
}

variable "app_desired_count" {
  description = "Desired number of app task instances"
  type        = number
  default     = 2
}

variable "app_cpu" {
  description = "CPU units for app container (1024 = 1 vCPU)"
  type        = number
  default     = 512
}

variable "app_memory" {
  description = "Memory for app container in MB"
  type        = number
  default     = 1024
}

variable "mongo_image" {
  description = "MongoDB Docker image"
  type        = string
  default     = "mongo:7.0"
}

variable "mongo_port" {
  description = "MongoDB port"
  type        = number
  default     = 27017
}

variable "mongo_cpu" {
  description = "CPU units for MongoDB container (1024 = 1 vCPU)"
  type        = number
  default     = 512
}

variable "mongo_memory" {
  description = "Memory for MongoDB container in MB"
  type        = number
  default     = 1024
}