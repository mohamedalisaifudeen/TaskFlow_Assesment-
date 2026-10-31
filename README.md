# TaskFlow Platform Engineer  Assessment Solution

Production grade Spring Boot 3 microservice infrastructure on AWS ECS (EC2 launch type), fully automated using Terraform IaC, Ansible Configuration Management, and GitHub Actions CI/CD.

## Tech Stack
* **Application:** Spring Boot 3.2.5, Java 17, Maven, PostgreSQL Driver, Swagger/OpenAPI.
* **Containerization:** Docker (Multi-stage Alpine JRE build, non-root user execution).
* **Infrastructure as Code:** Terraform >= 1.5.0 (Modular VPC, IAM, RDS PostgreSQL, ALB, ECS Cluster, CloudWatch Scaling).
* **Configuration Management:** Ansible (AWS Dynamic Inventory, OS Hardening, Docker Engine setup).
* **CI/CD:** GitHub Actions (Automated compile, unit testing, ECR container build/push, Terraform validation).

---

## Repository Architecture

```text
GtnTechAssesment/
├── .github/workflows/
│   └── deploy.yml              # CI/CD Pipeline (Build, Test, Containerize, IaC checks)
├── app/                        # Spring Boot Application & Multi-stage Dockerfile
│   ├── src/
│   ├── pom.xml
│   └── Dockerfile
├── terraform/                  # Infrastructure as Code
│   ├── modules/                # Reusable Infrastructure Modules
│   │   ├── vpc/                # Multi-AZ VPC, Subnets, IGW, NAT Gateway
│   │   ├── iam/                # Task Execution & EC2 IAM Roles/Policies
│   │   ├── rds/                # PostgreSQL RDS & AWS Secrets Manager
│   │   ├── alb/                # Application Load Balancer & Target Groups
│   │   ├── ecs/                # ECS Cluster, Launch Templates, ASG, Task Definitions
│   │   └── scaling/            # CloudWatch CPU & Memory Alarm Monitoring
│   └── envs/prod/              # Production Root Deployment Environment
├── ansible/                    # Server Configuration Management
│   ├── inventory/aws_ec2.yml   # AWS Dynamic Host Discovery Plugin
│   ├── roles/
│   │   ├── os_hardening/       # Package updates, SSH key enforcement, root restriction
│   │   └── docker/             # Docker engine installation & systemd daemon lifecycle
│   ├── ansible.cfg             # Ansible engine configuration
│   └── site.yml                # Master Playbook
├── docs/                       # Operational Documentation & Architecture Decisions
│   ├── adr/001-infrastructure-decisions.md
│   └── RUNBOOK.md
└── evidence/                   # Proof of Execution Logs
    └── health-check.txt