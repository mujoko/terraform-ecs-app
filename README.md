# ECS App with MongoDB Terraform Module

This Terraform project creates a complete infrastructure for running a web application with MongoDB on AWS ECS Fargate.

## Architecture

The infrastructure includes:

- **VPC**: Custom VPC with public subnets across multiple availability zones
- **ECS Cluster**: Fargate-based cluster for running containerized applications
- **Application Load Balancer**: Internet-facing ALB for public access to the app
- **ECS Services**: 
  - App service (from your ECR image)
  - MongoDB service (from public Docker Hub)
- **Security Groups**: Properly configured for secure communication
- **Service Discovery**: Private DNS namespace for internal service communication
- **CloudWatch Logs**: Centralized logging for both services

## Architecture Diagram

```
Internet
    |
    v
Application Load Balancer (Public)
    |
    v
App ECS Service (Fargate)
    |
    v (Internal via Service Discovery)
MongoDB ECS Service (Fargate)
```

## Security

- **ALB**: Accepts HTTP traffic from the internet (0.0.0.0/0) on port 80
- **App Service**: Only accepts traffic from the ALB on the configured app port
- **MongoDB Service**: Only accepts traffic from the App Service on port 27017
- **Network**: All services run in public subnets but MongoDB is not directly accessible from the internet

## Prerequisites

1. AWS CLI configured with appropriate permissions
2. Terraform >= 1.5.0 installed
3. An ECR repository with your application image
4. Your application should:
   - Listen on a configurable port (default: 8080)
   - Have a health check endpoint at `/health` (or modify the health check in the code)
   - Connect to MongoDB using the `MONGO_URL` environment variable

## Quick Start

1. **Clone and navigate to the project:**
   ```bash
   git clone <your-repo>
   cd terraform-ecs-app
   ```

2. **Create terraform.tfvars:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit terraform.tfvars with your values:**
   ```hcl
   # AWS Configuration
   aws_region = "us-east-1"
   
   # Project Configuration  
   name_prefix = "my-app"
   environment = "dev"
   
   # Application Configuration
   app_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
   app_container_port = 8080
   ```

4. **Deploy the infrastructure:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

5. **Access your application:**
   After deployment, your app will be available at the ALB DNS name shown in the output.

## Configuration Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `app_image` | ECR image URI for your application | `123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest` |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | AWS region |
| `name_prefix` | `my-app` | Prefix for resource naming |
| `environment` | `dev` | Environment name |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `public_subnet_cidrs` | `["10.0.1.0/24", "10.0.2.0/24"]` | Public subnet CIDRs |
| `app_container_port` | `8080` | Port your app listens on |
| `app_desired_count` | `2` | Number of app instances |
| `app_cpu` | `512` | CPU units (1024 = 1 vCPU) |
| `app_memory` | `1024` | Memory in MB |
| `mongo_image` | `mongo:7.0` | MongoDB Docker image |
| `mongo_port` | `27017` | MongoDB port |
| `mongo_cpu` | `512` | MongoDB CPU units |
| `mongo_memory` | `1024` | MongoDB memory in MB |

## Outputs

| Output | Description |
|--------|-------------|
| `app_load_balancer_dns` | ALB DNS name for accessing your app |
| `vpc_id` | Created VPC ID |
| `ecs_cluster_id` | ECS cluster ID |
| `app_service_arn` | App ECS service ARN |
| `mongo_service_arn` | MongoDB ECS service ARN |

## Application Requirements

Your application should be configured to:

1. **Listen on the configured port** (set via `PORT` environment variable)
2. **Connect to MongoDB** using the `MONGO_URL` environment variable
3. **Provide a health check** endpoint at `/health` that returns HTTP 200

### Example Environment Variables Available to Your App:

```bash
MONGO_URL=mongodb://my-app-mongo.my-app-cluster.local:27017
PORT=8080
```

## MongoDB Configuration

The MongoDB container is configured with:
- Username: `admin`
- Password: `password`
- No persistent volume (data will be lost when container restarts)

For production use, consider:
- Using AWS Secrets Manager for credentials
- Adding EFS or EBS volumes for data persistence
- Implementing backup strategies

## Monitoring and Logs

- **CloudWatch Logs**: Both app and MongoDB logs are sent to CloudWatch
- **Container Insights**: Enabled on the ECS cluster for detailed monitoring
- **Health Checks**: ALB health checks ensure only healthy app instances receive traffic

## Scaling

To scale your application:

```bash
# Update terraform.tfvars
app_desired_count = 4

# Apply changes
terraform apply
```

## Cleanup

To destroy all created resources:

```bash
terraform destroy
```

## Customization

The modules are designed to be flexible. You can:

1. **Modify security groups** in `modules/ecs/main.tf`
2. **Add private subnets** for enhanced security
3. **Configure SSL/TLS** by adding HTTPS listener to the ALB
4. **Add auto-scaling** policies for the ECS services
5. **Integrate with AWS Secrets Manager** for sensitive data

## Troubleshooting

### Common Issues

1. **App not accessible**: Check security groups and ALB health checks
2. **MongoDB connection issues**: Verify service discovery and security groups
3. **Task startup failures**: Check CloudWatch logs for container errors
4. **Resource limits**: Ensure CPU/memory settings are appropriate

### Useful Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster my-app-cluster --services my-app-app-service

# View logs
aws logs tail /ecs/my-app-app --follow

# Check ALB health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.