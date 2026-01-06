# Enterprise Productivity Monitoring System
# Production Infrastructure Configuration
# Terraform v1.0+

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }

  backend "s3" {
    bucket         = "enterprise-productivity-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

# Configure providers
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = "production"
      Project     = "enterprise-productivity-monitoring"
      ManagedBy   = "terraform"
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Local values
locals {
  name_prefix = "epm-prod"
  common_tags = {
    Environment = "production"
    Project     = "enterprise-productivity-monitoring"
    ManagedBy   = "terraform"
  }
}

# VPC and Networking
module "vpc" {
  source = "../../modules/networking"
  
  name_prefix          = local.name_prefix
  cidr_block          = var.vpc_cidr
  availability_zones  = data.aws_availability_zones.available.names
  enable_nat_gateway  = true
  enable_vpn_gateway  = false
  enable_dns_hostnames = true
  enable_dns_support  = true
  
  tags = local.common_tags
}

# Security Groups
module "security_groups" {
  source = "../../modules/security"
  
  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id
  
  tags = local.common_tags
}

# EKS Cluster
module "eks" {
  source = "../../modules/compute"
  
  name_prefix    = local.name_prefix
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
  
  cluster_version = var.kubernetes_version
  
  node_groups = {
    main = {
      instance_types = ["t3.large", "t3.xlarge"]
      capacity_type  = "ON_DEMAND"
      min_size      = 2
      max_size      = 10
      desired_size  = 3
      
      labels = {
        role = "main"
      }
      
      taints = []
    }
    
    compute = {
      instance_types = ["c5.xlarge", "c5.2xlarge"]
      capacity_type  = "SPOT"
      min_size      = 0
      max_size      = 5
      desired_size  = 1
      
      labels = {
        role = "compute"
        workload = "ml"
      }
      
      taints = [
        {
          key    = "workload"
          value  = "ml"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }
  
  tags = local.common_tags
}

# RDS PostgreSQL
module "database" {
  source = "../../modules/storage"
  
  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnet_ids
  
  # PostgreSQL configuration
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.r6g.xlarge"
  
  allocated_storage     = 100
  max_allocated_storage = 1000
  storage_encrypted     = true
  
  database_name = "enterprise_productivity"
  username      = "postgres"
  
  # High availability
  multi_az               = true
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # Performance monitoring
  performance_insights_enabled = true
  monitoring_interval         = 60
  
  # Security
  deletion_protection = true
  skip_final_snapshot = false
  
  tags = local.common_tags
}

# ElastiCache Redis
module "cache" {
  source = "../../modules/storage"
  
  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnet_ids
  
  # Redis configuration
  engine               = "redis"
  engine_version       = "7.0"
  node_type           = "cache.r6g.large"
  num_cache_clusters  = 2
  
  # High availability
  automatic_failover_enabled = true
  multi_az_enabled          = true
  
  # Security
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token_enabled        = true
  
  tags = local.common_tags
}

# S3 Buckets
module "storage" {
  source = "../../modules/storage"
  
  name_prefix = local.name_prefix
  
  buckets = {
    screenshots = {
      versioning_enabled = true
      lifecycle_rules = [
        {
          id     = "screenshot_lifecycle"
          status = "Enabled"
          
          transitions = [
            {
              days          = 30
              storage_class = "STANDARD_IA"
            },
            {
              days          = 90
              storage_class = "GLACIER"
            }
          ]
          
          expiration = {
            days = 2555 # 7 years
          }
        }
      ]
    }
    
    backups = {
      versioning_enabled = true
      lifecycle_rules = [
        {
          id     = "backup_lifecycle"
          status = "Enabled"
          
          transitions = [
            {
              days          = 1
              storage_class = "GLACIER"
            }
          ]
          
          expiration = {
            days = 2555 # 7 years
          }
        }
      ]
    }
    
    logs = {
      versioning_enabled = false
      lifecycle_rules = [
        {
          id     = "log_lifecycle"
          status = "Enabled"
          
          expiration = {
            days = 90
          }
        }
      ]
    }
  }
  
  tags = local.common_tags
}

# Application Load Balancer
module "load_balancer" {
  source = "../../modules/networking"
  
  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.public_subnet_ids
  
  # SSL Certificate
  certificate_arn = var.ssl_certificate_arn
  
  # Security
  enable_waf = true
  
  tags = local.common_tags
}

# CloudFront Distribution
module "cdn" {
  source = "../../modules/networking"
  
  name_prefix = local.name_prefix
  
  # Origins
  origins = {
    api = {
      domain_name = module.load_balancer.dns_name
      origin_path = "/api"
    }
    
    static = {
      domain_name = module.storage.bucket_domain_names["static"]
      origin_path = ""
    }
  }
  
  # SSL Certificate
  certificate_arn = var.cloudfront_certificate_arn
  
  tags = local.common_tags
}

# Monitoring and Logging
module "monitoring" {
  source = "../../modules/monitoring"
  
  name_prefix = local.name_prefix
  
  # CloudWatch Log Groups
  log_groups = [
    "/aws/eks/${local.name_prefix}-cluster/cluster",
    "/aws/rds/instance/${local.name_prefix}-postgres/postgresql",
    "/aws/elasticache/${local.name_prefix}-redis",
    "/aws/lambda/${local.name_prefix}-functions"
  ]
  
  # CloudWatch Alarms
  enable_database_alarms = true
  enable_cluster_alarms  = true
  enable_application_alarms = true
  
  # SNS Topics for alerts
  alert_email = var.alert_email
  
  tags = local.common_tags
}

# Secrets Manager
resource "aws_secretsmanager_secret" "database_credentials" {
  name        = "${local.name_prefix}-database-credentials"
  description = "Database credentials for production environment"
  
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "database_credentials" {
  secret_id = aws_secretsmanager_secret.database_credentials.id
  secret_string = jsonencode({
    username = module.database.username
    password = module.database.password
    endpoint = module.database.endpoint
    port     = module.database.port
    dbname   = module.database.database_name
  })
}

resource "aws_secretsmanager_secret" "redis_credentials" {
  name        = "${local.name_prefix}-redis-credentials"
  description = "Redis credentials for production environment"
  
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "redis_credentials" {
  secret_id = aws_secretsmanager_secret.redis_credentials.id
  secret_string = jsonencode({
    endpoint   = module.cache.endpoint
    port       = module.cache.port
    auth_token = module.cache.auth_token
  })
}

# IAM Roles and Policies
module "iam" {
  source = "../../modules/security"
  
  name_prefix = local.name_prefix
  
  # Service roles
  create_eks_service_role = true
  create_node_group_role  = true
  create_lambda_role      = true
  
  # Application-specific policies
  s3_bucket_arns = [
    module.storage.bucket_arns["screenshots"],
    module.storage.bucket_arns["backups"],
    module.storage.bucket_arns["logs"]
  ]
  
  secrets_manager_arns = [
    aws_secretsmanager_secret.database_credentials.arn,
    aws_secretsmanager_secret.redis_credentials.arn
  ]
  
  tags = local.common_tags
}

# Route53 DNS
resource "aws_route53_zone" "main" {
  name = var.domain_name
  
  tags = local.common_tags
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = module.load_balancer.dns_name
    zone_id                = module.load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cdn" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "cdn.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = module.cdn.domain_name
    zone_id                = module.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

# Backup and Disaster Recovery
module "backup" {
  source = "../../modules/backup"
  
  name_prefix = local.name_prefix
  
  # RDS Backup
  rds_instance_arn = module.database.arn
  
  # EBS Backup
  eks_cluster_name = module.eks.cluster_name
  
  # S3 Cross-Region Replication
  source_bucket_arns = [
    module.storage.bucket_arns["screenshots"],
    module.storage.bucket_arns["backups"]
  ]
  
  destination_region = var.backup_region
  
  tags = local.common_tags
}

# Output values
output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = module.database.endpoint
  sensitive   = true
}

output "redis_endpoint" {
  description = "ElastiCache Redis endpoint"
  value       = module.cache.endpoint
  sensitive   = true
}

output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = module.load_balancer.dns_name
}

output "cdn_domain" {
  description = "CloudFront distribution domain"
  value       = module.cdn.domain_name
}

output "s3_bucket_names" {
  description = "S3 bucket names"
  value       = module.storage.bucket_names
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}