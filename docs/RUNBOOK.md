# Section 3.3: TaskFlow Operational Runbook

This runbook outlines standard operating procedures, execution steps, monitoring guidelines, and incident response protocols for the TaskFlow platform.

---

## 1. System Overview & Prerequisites

### Architecture Summary

- **Application:** Spring Boot 3.2.5 microservice running on Java 17 (Port 8080).
- **Container:** Multi-stage Docker build running on Alpine Linux with a non-root system user.
- **Infrastructure:** AWS Multi-AZ VPC, Application Load Balancer (ALB), ECS Cluster (EC2 launch type), and RDS PostgreSQL.
- **Configuration:** Ansible-driven OS hardening and Docker engine deployment.
- **CI/CD:** GitHub Actions pipeline (`.github/workflows/deploy.yml`).

### Operator Tooling Requirements

- Docker Desktop `>= 24.0`
- Java JDK `17` & Maven `>= 3.8`
- Terraform CLI `>= 1.5.0`
- Ansible Engine `>= 2.15`
- AWS CLI `v2`

---

## 2. Local Execution & Container Lifecycle

### 2.1 Application Compilation & Local Run

```bash
# Navigate to the app directory
cd app

# Compile and run unit tests
mvn clean test package

# Run locally
java -jar target/taskflow-0.0.1-SNAPSHOT.jar
```

### 2.2 Docker Image Build & Local Container Verification

```bash
# Build multi-stage container image
docker build -t taskflow:v1.0.0 ./app

# Run container isolated on port 8080
docker run -d \
  --name taskflow-app \
  -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=local \
  taskflow:v1.0.0

# Verify container running state
docker ps --filter "name=taskflow-app"
```

### 2.3 Local Health Check & Endpoint Audit

```bash
# Verify application health status
curl -i http://localhost:8080/health

# Expected HTTP Response:
# HTTP/1.1 200 OK
# Content-Type: application/json
# {"status":"UP"}
```

---

## 3. Infrastructure Operations (Terraform)

### 3.1 Initializing & Validating Modules

```bash
cd terraform/envs/prod

# Initialize provider plugins and remote backend modules
terraform init

# Validate HCL syntax and configuration references
terraform validate
```

### 3.2 Execution & Planning

```bash
# Generate execution plan
terraform plan -out=tfplan

# Apply changes to provision infrastructure
terraform apply tfplan

# Tear down environment resources (Emergency / Teardown only)
terraform destroy
```

---

## 4. Configuration Management (Ansible)

### 4.1 Local Playbook Syntax Check

```bash
cd ansible

# Check syntax against local inventory target
ansible-playbook --syntax-check -i "localhost," site.yml
```

### 4.2 Executing OS Hardening & Engine Setup

```bash
# Execute against live AWS infrastructure via Dynamic Inventory
ansible-playbook -i inventory/aws_ec2.yml site.yml
```

---

## 5. CI/CD Operations & Pipeline Management

The GitHub Actions workflow runs automatically on `push` or `pull_request` to `main` or `master`.

### Automated Pipeline Stages

1. **Build & Test Java App:** Executes Maven test runner and compiles the executable JAR.
2. **Build Docker & Push to ECR:** Tags the image with Git SHA and `latest`, then pushes to AWS ECR.
3. **Terraform Validate & Plan:** Performs syntax validation and checks structural integrity.
4. **Ansible Syntax Check:** Validates YAML playbooks and execution roles.
5. **Deploy to AWS ECS Cluster:** Triggers a rolling update using `aws ecs update-service --force-new-deployment`.

---

## 6. Incident Response & Troubleshooting Playbook

### Scenario A: Application Health Check Failure (HTTP 502 / 503 on ALB)

1. **Inspect Local/Container Logs:**

   ```bash
   docker logs taskflow-app --tail 100
   ```

2. **Inspect ECS Container Logs:**

   ```bash
   aws logs tail /ecs/prod-taskflow --follow --region us-east-1
   ```

3. **Common Root Causes:**
    - Missing or invalid database secret credentials injected via Secrets Manager.
    - Target group health check path misconfigured. It must target `/health` on port `8080`.

### Scenario B: Database Connection Timeout

1. **Verify RDS Network Reachability:**
    - Ensure the RDS security group explicitly permits inbound port `5432` traffic from the ECS host security group.
    - Confirm RDS resides within the private subnets.

2. **Check Database Credentials:**
    - Inspect the AWS Secrets Manager payload for keys matching the Spring datasource configuration.

### Scenario C: High CPU / Memory Scale Alarm Triggered

1. **Check CloudWatch Alarms:**
    - High CPU (>85%) or High Memory (>80%) alarm notification received.

2. **Action:**
    - The ECS Auto Scaling Group dynamically provisions additional EC2 host instances and task replicas.
    - If manual intervention is needed, scale the task count directly:

   ```bash
   aws ecs update-service \
     --cluster prod-taskflow-cluster \
     --service prod-taskflow-service \
     --desired-count 4 \
     --region us-east-1
   ```