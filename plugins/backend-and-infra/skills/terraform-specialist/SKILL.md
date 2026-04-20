---
name: terraform-specialist
description: Write Terraform modules, manage state, and implement IaC best practices. Use when writing Terraform code, creating reusable modules, managing remote state, planning infrastructure changes, or migrating existing resources to Terraform.
---

# Terraform Specialist

Guidelines for infrastructure automation and Terraform best practices.

## Core Principles

1. **DRY with modules** - Reusable, versioned components
2. **State is sacred** - Always use remote state with locking
3. **Plan before apply** - Review every change
4. **Lock versions** - Pin providers and modules
5. **Use data sources** - Avoid hardcoded values

## Project Structure

```
infrastructure/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   └── prod/
├── modules/
│   ├── vpc/
│   ├── ecs-service/
│   └── rds/
└── global/
    ├── iam/
    └── dns/
```

## Provider Configuration

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "mycompany-terraform-state"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = var.project_name
    }
  }
}
```

## Module Design

### Module Structure

```
modules/vpc/
├── main.tf           # Primary resources
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── versions.tf       # Provider requirements
├── locals.tf         # Local values
└── README.md         # Documentation
```

### Module Example

```hcl
# modules/vpc/variables.tf
variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

# modules/vpc/main.tf
resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "public" {
  count = length(var.azs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.cidr, 8, count.index)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-${var.azs[count.index]}"
    Type = "public"
  }
}

# modules/vpc/outputs.tf
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}
```

### Using Modules

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name               = "myapp-${var.environment}"
  cidr               = "10.0.0.0/16"
  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  enable_nat_gateway = var.environment == "prod"
}

# Reference outputs
resource "aws_instance" "app" {
  subnet_id = module.vpc.public_subnet_ids[0]
}
```

## Variables Best Practices

```hcl
# Use validation
variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# Use object types for complex variables
variable "database_config" {
  description = "Database configuration"
  type = object({
    instance_class    = string
    allocated_storage = number
    engine_version    = string
    multi_az          = bool
  })

  default = {
    instance_class    = "db.t3.micro"
    allocated_storage = 20
    engine_version    = "14.7"
    multi_az          = false
  }
}

# Sensitive variables
variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}
```

## Locals for Computed Values

```hcl
locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  # Conditional logic
  instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"

  # Dynamic subnet calculation
  subnet_cidrs = [for i in range(3) : cidrsubnet(var.vpc_cidr, 8, i)]
}
```

## Data Sources

```hcl
# Look up AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Look up existing VPC
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["main-vpc"]
  }
}

# Current AWS account
data "aws_caller_identity" "current" {}

# Current region
data "aws_region" "current" {}
```

## Lifecycle Rules

```hcl
resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  lifecycle {
    # Prevent accidental destruction
    prevent_destroy = true

    # Create new before destroying old
    create_before_destroy = true

    # Ignore external changes
    ignore_changes = [
      tags["LastModified"],
      user_data
    ]
  }
}
```

## Import Existing Resources

```hcl
# 1. Write the resource block
resource "aws_s3_bucket" "existing" {
  bucket = "my-existing-bucket"
}

# 2. Import into state
# terraform import aws_s3_bucket.existing my-existing-bucket

# 3. Run plan to verify
# terraform plan

# For Terraform 1.5+, use import blocks
import {
  to = aws_s3_bucket.existing
  id = "my-existing-bucket"
}
```

## State Management

### Remote State Data Source

```hcl
# Access outputs from another state file
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "mycompany-terraform-state"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# Use the outputs
resource "aws_instance" "app" {
  subnet_id = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
}
```

### State Commands

```bash
# List resources in state
terraform state list

# Show specific resource
terraform state show aws_instance.app

# Move resource (rename)
terraform state mv aws_instance.old aws_instance.new

# Remove from state (without destroying)
terraform state rm aws_instance.legacy

# Pull remote state locally
terraform state pull > backup.tfstate
```

## Workspaces

```bash
# Create and switch workspace
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# List workspaces
terraform workspace list

# Switch workspace
terraform workspace select dev

# Use in config
resource "aws_instance" "app" {
  count = terraform.workspace == "prod" ? 3 : 1
  tags = {
    Environment = terraform.workspace
  }
}
```

## Common Patterns

### Count vs For Each

```hcl
# count - for identical resources
resource "aws_subnet" "public" {
  count      = 3
  cidr_block = cidrsubnet(var.cidr, 8, count.index)
}

# for_each - for unique resources (preferred)
resource "aws_iam_user" "users" {
  for_each = toset(["alice", "bob", "carol"])
  name     = each.key
}

# for_each with map
variable "instances" {
  default = {
    web = { type = "t3.micro", az = "us-east-1a" }
    api = { type = "t3.small", az = "us-east-1b" }
  }
}

resource "aws_instance" "app" {
  for_each          = var.instances
  instance_type     = each.value.type
  availability_zone = each.value.az
  tags = { Name = each.key }
}
```

### Dynamic Blocks

```hcl
resource "aws_security_group" "this" {
  name = "app-sg"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```
