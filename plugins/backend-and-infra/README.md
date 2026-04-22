# backend-and-infra

Backend development, infrastructure, Docker, Terraform, and language-specific practices for Go, Python, TypeScript, and JavaScript.

## Skills

| Skill | Purpose |
|---|---|
| `backend-architect` | System design and architecture decisions |
| `backend-patterns` | Common backend patterns (auth, caching, queues) |
| `deploying-applications` | Deployment strategies for Docker, Kubernetes, CI/CD |
| `docker-patterns` | Docker and Docker Compose best practices |
| `golang-pro` | Go development patterns and idioms |
| `javascript-pro` | JavaScript patterns and Node.js practices |
| `python-pro` | Python development and testing patterns |
| `terraform-specialist` | Terraform modules, state, and AWS provisioning |
| `typescript-pro` | TypeScript patterns and type design |
| `automating-tests` | Test automation strategies across languages |
| `homelab-helper` | Self-hosting, Raspberry Pi, Docker Compose stacks |

## Requirements

Most skills are reference-only and need no tools installed. Skills that generate or run code assume:

| Tool | Skills that use it | Install |
|---|---|---|
| Docker + Docker Compose | `docker-patterns`, `deploying-applications` | [docs.docker.com](https://docs.docker.com/get-docker/) |
| Terraform | `terraform-specialist` | `brew install terraform` |
| Go | `golang-pro` | `brew install go` |
| Python 3.11+ | `python-pro`, `automating-tests` | `brew install python` |
| Node.js 18+ | `javascript-pro`, `typescript-pro` | `brew install node` |
| kubectl | `deploying-applications` (Kubernetes targets) | `brew install kubectl` |
| gh CLI | `deploying-applications` (GitHub Actions) | `brew install gh` |

## Environment Variables

These are only relevant when the skills generate deployment configs targeting real infrastructure:

- `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` — Terraform AWS provider
- `KUBE_CONFIG` — Kubernetes deployments via GitHub Actions

## Notes

- `homelab-helper` is tailored to Alex's Raspberry Pi 5 setup — adjust service recommendations for your own hardware
- `terraform-specialist` assumes an S3 + DynamoDB remote state backend; update the backend config block if using a different provider
