variable "region" {
  description = "AWS Region"
  default     = "ap-south-1"
}
variable "access_key" {
    description = "acess key"
    default = "AKIA47GB7XXEPHFSZ3NQ"
  
}
variable "secret_key" {
    description ="secret_key"
    default = "dmHeSoeCWUJl78whcSPa+m37LCSqMr0jxiB78Ccz"
  
}
# VPC
variable "vpc_cidr_block" {
  description = "VPC network CIDR block"
  default     = "10.1.0.0/16"
}

variable "public_subnet_a_cidr_block" {
  description = "Public Subnet A CIDR block"
  default     = "10.1.4.0/24"
}
variable "public_subnet_a_cidr_block2" {
  description = "Public Subnet A CIDR block"
  default     = "10.1.5.0/24"
}

variable "private_subnet_a_cidr_block" {
  description = "Private Subnet A CIDR block"
  default     = "10.1.2.0/24"
}

variable "private_subnet_b_cidr_block" {
  description = "Private Subnet B CIDR block"
  default     = "10.1.3.0/24"
}

# RDS
variable "db_instance_type" {
  description = "RDS instance type"
  default     = "db.t3.small"
}

variable "db_name" {
  description = "RDS database name"
  default     = "mywordpressdb"
}

variable "db_user" {
  description = "RDS database username"
  default     = "wp_admin"
}

variable "db_password" {
  description = "RDS database password"
  default     = "SecurePass123!"  # Consider using AWS Secrets Manager for security
}

# ECS Cluster
variable "ecs_cluster_name" {
  description = "ECS cluster name"
  default     = "ecs-wordpress"
}

# EC2 Instance Type for ECS
variable "ecs_instance_type" {
  description = "EC2 instance type for ECS cluster"
  default     = "t3.large"
}

variable "key_pair_name" {
  description = "Key pair name for SSH access"
  default     = "task"
}

# Autoscaling
variable "ecs_desired_capacity" {
  description = "Desired capacity for ECS autoscaling group"
  default     = 2
}

variable "ecs_min_size" {
  description = "Minimum number of ECS instances"
  default     = 1
}

variable "ecs_max_size" {
  description = "Maximum number of ECS instances"
  default     = 3
}
