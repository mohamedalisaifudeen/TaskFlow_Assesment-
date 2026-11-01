
# TaskFlow Platform Engineer Assessment Solution

Production-grade Spring Boot 3 microservice infrastructure on AWS ECS (EC2 launch type), fully automated using Terraform IaC, Ansible Configuration Management, and GitHub Actions CI/CD.

---

## 1. Technical Essays

### 1.1 Comparative Essay: DevOps vs. Platform Engineering

#### The Evolution of DevOps
DevOps emerged to dissolve operational silos between software developers and IT operations teams. Adopting the core philosophy of *"you build it, you run it,"* DevOps cross-functional teams took end-to-end ownership of the application lifecycle, from coding and testing to provisioning infrastructure, monitoring, and incident management.

However, as cloud infrastructure expanded into complex Kubernetes clusters, multi region networking, granular IAM policies, and serverless architectures, a major friction point emerged: **developer cognitive overload**. Software engineers were spending substantial time deciphering infrastructure definitions, complex pipeline configs, and cloud access policies rather than shipping core business logic.

#### The Rise of Platform Engineering
Platform Engineering emerged to address this cognitive overload by designing an abstraction layer between application developers and underlying cloud infrastructure.

Instead of expecting every software engineer to operate as a full-stack cloud architect, Platform Engineering teams build and manage an **Internal Developer Platform (IDP)**. This platform delivers standardized self-service infrastructure templates, automated CI/CD "golden paths," and pre-configured security baseline policies.

#### Core Distinctions

| Metric / Dimension | Traditional DevOps | Platform Engineering |
| :--- | :--- | :--- |
| **Primary Goal** | Streamline Dev & Ops collaboration | Reduce cognitive friction & standardize platform tooling |
| **Operating Model** | Shared operational responsibility across engineers | Platform Team operates "Platform as a Product" for internal devs |
| **Developer Interface** | Direct interaction with IaC, CI/CD YAML, & Cloud Consoles | Golden Paths, CLI abstractions, Developer Portals (e.g., Backstage) |
| **Infrastructure Access** | Custom manual/semi-automated provisioning per service | Automated Self-Service via policy-governed reusable templates |

#### Synergy Between the Paradigms
Platform Engineering does not replace DevOps, rather, it represents **DevOps at scale**. DevOps provides the cultural principles (automation, continuous feedback, shared ownership), while Platform Engineering provides the structural mechanism to scale those principles seamlessly across large engineering organizations.

---

### 1.2 Technical Analysis: The DevSecOps Paradigm Shift

#### Why DevSecOps Matters
Traditionally, security was treated as a gatekeeper audit conducted at the end of the software development lifecycle (SDLC). Security teams performed manual penetration testing and compliance audits right before production releases, causing deployment bottlenecks, developer friction, and high remediation costs when vulnerabilities were discovered late.

**DevSecOps** fundamentally shifts security **"left"**—integrating automated security controls, policy enforcement, and vulnerability analysis directly into every phase of the CI/CD pipeline.

#### Core Pillars of DevSecOps in Production

1. **Static & Dynamic Code Analysis (SAST/DAST):** Automated security scanners check application code for SQL injection, insecure dependencies, and hardcoded credentials during standard test execution (`mvn test`).
2. **Container & Image Scanning:** Multi-stage Docker builds reduce attack surfaces by deploying minimal runtime images (Alpine JRE). Images are automatically scanned for CVE vulnerabilities in container registries (AWS ECR / Trivy) before deployment.
3. **Infrastructure as Code (IaC) Governance:** Static analysis tools validate Terraform HCL files against security policies (e.g., enforcing private RDS instances, enforcing restricted SSH security groups, and requiring encryption at rest).
4. **Zero-Trust & Dynamic Secrets Management:** Storing hardcoded secrets in repositories is strictly prohibited. In this solution, AWS Secrets Manager dynamically generates and stores database credentials, injecting them into ECS tasks at runtime via scoped IAM execution roles.

By embedding security controls into automated pipelines, organizations turn security from a release blocker into an automated, continuous enabler—reducing security risk, guaranteeing compliance, and accelerating velocity.

---

## 2. Setup & Local Run Instructions

### Prerequisites
* **Java JDK:** 17
* **Build Tool:** Apache Maven 3.8+
* **Container Engine:** Docker Desktop 24.0+
* **Infrastructure as Code:** Terraform >= 1.5.0
* **Configuration Management:** Ansible Engine >= 2.15

### Local Application Execution
```bash
# 1. Clone repository & navigate to app directory
cd app

# 2. Compile and package application
mvn clean package -DskipTests

# 3. Build multi-stage Docker container image
docker build -t taskflow:v1.0.0 .

# 4. Run local container on port 8080
docker run -d -p 8080:8080 --name taskflow-app taskflow:v1.0.0

# 5. Verify application health check
curl -i http://localhost:8080/health
# Expected Output: HTTP/1.1 200 OK {"status":"UP"}