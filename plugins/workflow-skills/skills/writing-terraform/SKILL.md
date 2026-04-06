---
name: writing-terraform
description: Write Terraform modules, manage state files, and implement infrastructure as code best practices. Use when writing Terraform configurations, creating modules, managing state, configuring providers, or implementing IaC patterns.
---

> **[DEPRECATED]** Candidate for removal (2026-03-03). If unused by 2026-03-17, delete this skill.

# Terraform Best Practices

Create maintainable, reusable infrastructure code following Terraform conventions.

## Module Structure

```
terraform-module/
├── main.tf           # Primary resource definitions
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── versions.tf       # Provider version constraints
├── README.md         # Module documentation
└── examples/
    └── basic/
        ├── main.tf
        └── terraform.tfvars.example
```

## Core Principles

1. **DRY** - Don't Repeat Yourself (use modules)
2. **State is sacred** - Always backup, never edit manually
3. **Plan before apply** - Always review changes
4. **Lock versions** - Pin provider versions
5. **Use data sources** - Avoid hardcoded values

## Variables and Outputs

### Input Variables

```hcl
# variables.tf

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_config" {
  description = "VPC configuration"
  type = object({
    cidr_block           = string
    enable_dns_hostnames = bool
    availability_zones   = list(string)
  })
}
```

### Output Values

```hcl
# outputs.tf

output "instance_ids" {
  description = "IDs of created instances"
  value       = aws_instance.app[*].id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

# Sensitive outputs
output "database_password" {
  description = "Database password"
  value       = random_password.db_password.result
  sensitive   = true
}
```

## Resource Configuration

### Naming and Tagging

```hcl
locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project_name
    }
  )

  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_instance" "app" {
  count = var.instance_count

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-app-${count.index + 1}"
      Role = "application"
    }
  )
}
```

### Dependencies

```hcl
# Implicit dependency (references another resource)
resource "aws_instance" "app" {
  subnet_id = aws_subnet.private.id  # Implicit dependency
}

# Explicit dependency (when needed)
resource "aws_iam_role_policy" "app" {
  role   = aws_iam_role.app.id
  policy = data.aws_iam_policy_document.app.json

  depends_on = [aws_iam_role.app]
}
```

### Count vs For_Each

```hcl
# ✅ Use for_each for map-like resources
resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = each.key
  }
}

# Usage in tfvars
private_subnets = {
  "subnet-a" = { cidr = "10.0.1.0/24", az = "us-east-1a" }
  "subnet-b" = { cidr = "10.0.2.0/24", az = "us-east-1b" }
}

# ✅ Use count for identical resources
resource "aws_instance" "worker" {
  count = var.worker_count

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "worker-${count.index + 1}"
  }
}
```

## State Management

### Remote Backend (S3)

```hcl
# versions.tf

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"

    # State versioning
    versioning = true
  }
}
```

### State Commands

```bash
# List resources in state
terraform state list

# Show specific resource
terraform state show aws_instance.app

# Move resource in state
terraform state mv aws_instance.old aws_instance.new

# Remove resource from state (doesn't delete)
terraform state rm aws_instance.temp

# Pull current state
terraform state pull > terraform.tfstate

# Import existing resource
terraform import aws_instance.app i-1234567890abcdef0
```

## Data Sources

```hcl
# Query existing resources
data "aws_vpc" "main" {
  id = var.vpc_id
}

# Use filters
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Query availability zones
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

# Use in resources
resource "aws_subnet" "public" {
  for_each = toset(data.aws_availability_zones.available.names)

  vpc_id            = aws_vpc.main.id
  availability_zone = each.value
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, index(data.aws_availability_zones.available.names, each.value))
}
```

## Modules

### Module Definition

```hcl
# modules/vpc/main.tf

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public-${each.key}"
      Type = "public"
    }
  )
}
```

### Module Usage

```hcl
# main.tf

module "vpc" {
  source = "./modules/vpc"

  name        = "production"
  cidr_block  = "10.0.0.0/16"

  public_subnets = {
    "us-east-1a" = { cidr = "10.0.1.0/24", az = "us-east-1a" }
    "us-east-1b" = { cidr = "10.0.2.0/24", az = "us-east-1b" }
  }

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}

# Use module outputs
resource "aws_instance" "app" {
  subnet_id = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.default_security_group_id]
}
```

## Workspace Management

```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new dev

# Switch workspace
terraform workspace select prod

# Show current workspace
terraform workspace show

# Use in config
resource "aws_instance" "app" {
  instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"

  tags = {
    Environment = terraform.workspace
  }
}
```

## Common Patterns

### Conditional Resources

```hcl
# Create resource only in production
resource "aws_cloudwatch_alarm" "app" {
  count = var.environment == "prod" ? 1 : 0

  alarm_name          = "app-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  threshold           = 80
}
```

### Dynamic Blocks

```hcl
resource "aws_security_group" "app" {
  name   = "app-sg"
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```

### Locals for Computed Values

```hcl
locals {
  # Flatten nested structures
  subnets = flatten([
    for az, subnets in var.availability_zones : [
      for subnet in subnets : {
        az         = az
        cidr       = subnet.cidr
        is_public  = subnet.public
      }
    ]
  ])

  # Conditional logic
  instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"

  # String manipulation
  name_suffix = lower(replace(var.project_name, " ", "-"))
}
```

## Best Practices Checklist

- [ ] Version constraints defined in versions.tf
- [ ] Remote state backend configured
- [ ] State locking enabled (DynamoDB for S3)
- [ ] Variables have descriptions and types
- [ ] Validation rules for inputs
- [ ] Outputs for important values
- [ ] Consistent naming convention
- [ ] Common tags applied to all resources
- [ ] Sensitive values marked as sensitive
- [ ] Data sources used instead of hardcoded values
- [ ] Modules for reusable components
- [ ] .gitignore includes .terraform/ and *.tfstate
- [ ] README documents module usage
- [ ] Examples directory with working examples
