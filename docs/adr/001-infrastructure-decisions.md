# ADR 001: Architecture & Infrastructure Decisions

## Status
**Accepted**

## Context

The TaskFlow Spring Boot 3 microservice requires a secure, highly available, and scalable deployment architecture on AWS. The infrastructure must support containerized application deployment, private database connectivity, automated infrastructure provisioning, operating system hardening, dynamic resource scaling, and continuous deployment.

The architecture must also ensure that sensitive credentials are securely managed, application workloads remain isolated from direct public access, and infrastructure configuration is reproducible through Infrastructure as Code (IaC).

## Decision Drivers

- **Security & Network Isolation:** Application servers and database instances must not be directly accessible from the public internet.
- **Infrastructure Control & Compliance:** The deployment environment must support OS-level hardening, security configuration, and custom container runtime settings.
- **High Availability:** Infrastructure components must be distributed across multiple Availability Zones to minimize single points of failure.
- **Scalability:** Application compute capacity must dynamically respond to workload fluctuations.
- **Cost Efficiency:** Infrastructure costs should be optimized without compromising operational requirements.
- **Automation:** Infrastructure provisioning, configuration management, and application deployment must be automated.

## Architectural Decisions

### 1. Compute Platform: Amazon ECS on EC2

**Decision:** Selected Amazon Elastic Container Service (ECS) with the EC2 launch type.

**Rationale:**

- Provides direct access to underlying EC2 instances for Ansible-based configuration management.
- Supports OS hardening, kernel-level security configurations, and custom Docker daemon settings.
- Enables greater control over container placement, instance types, and resource allocation.
- Allows EC2 Auto Scaling and ECS Capacity Providers to dynamically adjust compute capacity based on workload demand.
- Offers cost advantages for predictable, continuously running workloads where instance utilization can be optimized.

### 2. Network Architecture: Multi-AZ VPC with Public and Private Subnets

**Decision:** Implemented a Virtual Private Cloud (VPC) spanning two Availability Zones (`us-east-1a` and `us-east-1b`), containing two public and two private subnets.

**Rationale:**

- **Public Subnets:** Host the Application Load Balancer (ALB), which serves as the public entry point for incoming application traffic.
- **Private Application Subnets:** Host ECS container instances, preventing direct public internet access to application workloads.
- **Private Database Subnets:** Host the Amazon RDS PostgreSQL instance within an isolated database network.
- **Internet Gateway (IGW):** Provides internet connectivity to public subnet resources.
- **NAT Gateway:** Allows private subnet resources to initiate outbound connections for package installation, security updates, and external service access without exposing them to unsolicited inbound internet traffic.

This architecture separates application and database workloads from public-facing infrastructure while supporting multi-AZ availability.

### 3. Database & Secrets Management

**Decision:** Selected Amazon RDS for PostgreSQL database hosting and AWS Secrets Manager for sensitive credential management.

**Rationale:**

- Database credentials are generated dynamically using Terraform's `random_password` resource.
- Credentials are stored securely in AWS Secrets Manager rather than being hardcoded into application configuration or source code.
- ECS task definitions reference Secrets Manager values, allowing database credentials to be injected into application containers at runtime.
- IAM task execution roles provide the required permissions to retrieve secrets.
- Security groups restrict database connectivity to authorized application resources on the PostgreSQL port (5432).
- RDS is deployed within private database subnets with public accessibility disabled.

This approach reduces credential exposure and enforces least-privilege access to sensitive infrastructure resources.

### 4. Configuration Management: Ansible Dynamic Inventory

**Decision:** Implemented Ansible's `amazon.aws.aws_ec2` dynamic inventory plugin.

**Rationale:**

- Automatically discovers EC2 instances through AWS APIs without maintaining static IP address lists.
- Uses AWS resource tags and instance states to identify target infrastructure.
- Filters instances using attributes such as `Environment: prod` and `instance-state-name: running`.
- Supports automated OS configuration, security hardening, and Docker runtime customization.
- Simplifies configuration management when EC2 instances are replaced or scaled dynamically.

This eliminates dependency on manually maintained host inventories and improves infrastructure automation.

### 5. Monitoring & Auto Scaling

**Decision:** Implemented Amazon CloudWatch monitoring with CPU and memory utilization alarms, integrated with ECS capacity management.

**Rationale:**

- CPU utilization alarms monitor resource consumption against an 85% threshold.
- Memory utilization alarms monitor resource consumption against an 80% threshold.
- CloudWatch provides centralized monitoring, metrics collection, and operational visibility.
- Alarm notifications can be delivered to operations teams through Amazon SNS.
- ECS Service Auto Scaling adjusts the desired number of application tasks based on workload demand.
- ECS Capacity Providers integrate with EC2 Auto Scaling Groups to provision additional container instances when existing compute capacity is insufficient.

This approach supports workload-driven scaling while reducing the need for manual capacity management.

## Consequences

### Positive Consequences

- Improved security through private networking, IAM-based access control, and centralized secrets management.
- Better availability through multi-AZ infrastructure deployment.
- Greater infrastructure control through EC2-based container hosting.
- Reproducible infrastructure provisioning and configuration management using Terraform and Ansible.
- Improved operational visibility through CloudWatch monitoring.
- Automated application and infrastructure scaling based on workload demand.

### Trade-offs & Limitations

- ECS on EC2 introduces additional operational responsibilities, including EC2 instance maintenance and capacity management.
- NAT Gateways introduce additional infrastructure costs.
- Ansible configuration management requires secure administrative access to EC2 instances.
- Auto Scaling thresholds require monitoring and tuning to avoid unnecessary infrastructure costs or delayed scaling responses.

## Summary

The selected architecture combines Amazon ECS on EC2, a multi-AZ VPC, private RDS PostgreSQL, AWS Secrets Manager, Terraform, Ansible, and CloudWatch to establish a secure, automated, and scalable deployment platform for the TaskFlow Spring Boot 3 microservice.