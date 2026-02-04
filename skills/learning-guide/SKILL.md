---
name: learning-guide
description: Guide technical learning through hands-on projects and clear explanations. Use when exploring new technologies, creating learning paths, building practice projects, or understanding new concepts like Go, Terraform, Kubernetes, or AWS.
---

# Learning Guide

Structured approach to learning new technologies through hands-on practice.

## Learning Philosophy

1. **Start with why** - Understand the problem before the solution
2. **Learn by doing** - Hands-on projects over passive reading
3. **Build incrementally** - Small steps, gradual complexity
4. **Connect to existing knowledge** - Relate new concepts to familiar ones
5. **Experiment safely** - Use sandboxes and local environments

## Learning Path Template

When learning a new technology:

### 1. Orientation (30 min)
- What problem does this solve?
- When should I use it vs alternatives?
- What are the key concepts?

### 2. Hello World (1-2 hours)
- Minimal working example
- Understand the basic workflow
- Get something running

### 3. Guided Project (2-4 hours)
- Build something small but useful
- Follow a tutorial with modifications
- Document what you learn

### 4. Independent Project (4-8 hours)
- Apply to a real problem
- Make mistakes and debug
- Build muscle memory

### 5. Deep Dive (ongoing)
- Explore advanced features
- Read source code
- Contribute or share knowledge

## Technology Learning Paths

### Go Programming

**Week 1: Foundations**
```
Day 1-2: Syntax and Types
- Variables, functions, control flow
- Project: CLI calculator

Day 3-4: Data Structures
- Slices, maps, structs
- Project: Contact book CLI

Day 5-7: Packages and Testing
- Creating modules
- Writing tests
- Project: URL shortener library
```

**Week 2: Concurrency**
```
Day 1-2: Goroutines and Channels
- Project: Concurrent web scraper

Day 3-4: Sync Package
- Mutexes, WaitGroups
- Project: Rate-limited API client

Day 5-7: Real Application
- Project: Simple HTTP server with graceful shutdown
```

### Terraform / IaC

**Week 1: Core Concepts**
```
Day 1-2: HCL Basics
- Resources, variables, outputs
- Project: Create S3 bucket + IAM policy

Day 3-4: State Management
- Remote state, locking
- Project: Multi-file infrastructure

Day 5-7: Modules
- Creating reusable modules
- Project: VPC module with subnets
```

**Week 2: Real Infrastructure**
```
Day 1-3: Complete Application
- Project: Deploy containerized app to ECS

Day 4-5: Environments
- Workspaces or directory structure
- Project: Dev/Staging/Prod setup

Day 6-7: CI/CD Integration
- Project: GitHub Actions for terraform plan/apply
```

### Kubernetes

**Week 1: Local Development**
```
Day 1-2: Concepts
- Pods, Services, Deployments
- Project: Deploy nginx with minikube

Day 3-4: Configuration
- ConfigMaps, Secrets, Volumes
- Project: Stateful application with persistence

Day 5-7: Networking
- Services, Ingress
- Project: Multi-service application
```

**Week 2: Production Patterns**
```
Day 1-2: Scaling
- HPA, Resource limits
- Project: Auto-scaling deployment

Day 3-4: Observability
- Logs, metrics, health checks
- Project: Add monitoring to application

Day 5-7: Helm
- Charts and values
- Project: Create Helm chart for your app
```

## Project Ideas by Skill Level

### Beginner Projects
| Project | Technologies | Time |
|---------|-------------|------|
| Personal CLI tool | Go or Python | 2-4 hrs |
| Static site generator | Any language | 4-6 hrs |
| API wrapper library | TypeScript | 3-5 hrs |
| Docker dev environment | Docker Compose | 2-3 hrs |

### Intermediate Projects
| Project | Technologies | Time |
|---------|-------------|------|
| REST API with DB | Go/Python + PostgreSQL | 8-12 hrs |
| CI/CD pipeline | GitHub Actions | 4-6 hrs |
| Infrastructure module | Terraform + AWS | 6-8 hrs |
| Monitoring stack | Prometheus + Grafana | 4-6 hrs |

### Advanced Projects
| Project | Technologies | Time |
|---------|-------------|------|
| Microservices app | K8s + multiple services | 20+ hrs |
| Custom Terraform provider | Go + Terraform SDK | 15+ hrs |
| Full GitOps setup | ArgoCD + Helm | 10-15 hrs |
| Observability platform | OTEL + various backends | 15+ hrs |

## Learning Resources Strategy

### Official Documentation First
- Most accurate and up-to-date
- Often has tutorials and examples
- Understand the source of truth

### Interactive Learning
- **Go**: Go by Example, Tour of Go
- **Terraform**: HashiCorp Learn
- **Kubernetes**: Kubernetes.io tutorials
- **AWS**: AWS Skill Builder

### When to Use Tutorials
- Getting started with new concepts
- Understanding common patterns
- Seeing best practices in action

### When to Read Source Code
- Understanding implementation details
- Debugging unexpected behavior
- Learning advanced patterns

## Effective Practice Techniques

### Deliberate Practice
1. Set specific goals for each session
2. Focus on weak areas
3. Get immediate feedback
4. Reflect on what worked

### Spaced Repetition
- Review concepts at increasing intervals
- Build projects that reinforce learning
- Revisit old projects with new knowledge

### Teaching to Learn
- Write blog posts explaining concepts
- Create documentation for your projects
- Help others in communities

## Homelab as Learning Lab

Your homelab is perfect for practicing:

| Technology | Homelab Application |
|------------|---------------------|
| Docker | Deploy new services |
| Terraform | Manage cloud resources |
| Kubernetes | Run k3s cluster |
| Go | Build automation tools |
| Monitoring | Set up observability |

### Safe Experimentation
- Use separate VLANs for testing
- Snapshot VMs before changes
- Keep backups of working configs
- Document what you try

## Progress Tracking

### Learning Journal Format
```markdown
# [Date] - [Technology] - [Topic]

## What I Learned
- Key concept 1
- Key concept 2

## What I Built
- Description of project/exercise

## Challenges
- Problem I encountered
- How I solved it

## Next Steps
- [ ] What to learn next
- [ ] Project to try
```

### Skill Assessment
Rate yourself 1-5 on each technology:
1. Aware - Know it exists
2. Familiar - Understand basics
3. Competent - Can build simple things
4. Proficient - Can build complex things
5. Expert - Can teach others

Track progress monthly to see growth.
