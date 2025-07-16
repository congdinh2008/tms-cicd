Hello Copilot, here are the rules and context for this training project. Please adhere strictly to these guidelines to ensure the code is consistent, understandable, and suitable for training Junior Developers.

## 1. Project Context

This is a training project for Junior Developers, simulating a full-stack web application. The main objective is to familiarize new developers with a professional software development workflow, especially containerization, CI/CD, and Infrastructure as Code (IaC) following best practices.

**Tech Stack:**
- **Backend:** Java Spring Boot, using Maven, connected to PostgreSQL.
- **Frontend:** ReactJS using Vite and TypeScript.
- **Containerization:** **Docker** and **Docker Compose** for the local environment, with **Docker Hub** as the image registry.
- **CI/CD:** GitHub Actions.
- **Deployment:** Deploying containers on **Amazon ECS (Elastic Container Service)**.
- **Infrastructure as Code (IaC):** Terraform, with a modular structure.

---

## 2. Coding Style and Conventions

**General Principle:** Prioritize **clarity, simplicity, and readability**. Code should be well-commented to explain complex logic.

### **Backend - Java Spring Boot & Maven**
- **Structure:** Follow a feature-based structure.
- **Naming:** `PascalCase` for Classes, `camelCase` for methods/variables.
- **API:** Design according to RESTful standards.
- **Exception Handling:** Use `@ControllerAdvice`.
- **DTOs:** Always use DTOs; do not expose JPA Entities.
- **Logging:** Use SLF4J.
- **Maven:** Maintain a clean `pom.xml`, managing dependencies via `dependencyManagement`.
- **Jacoco:** using latest version: `0.8.13` for code coverage.

### **Frontend - ReactJS, Vite, TypeScript**
- **Components:** Create small, reusable components, each in its own folder.
- **Hooks:** Prefer Function Components and Hooks.
- **TypeScript:** Maximize type safety; avoid using `any`.
- **Styling:** Use CSS Modules or Styled-components.

### **Dockerfile and Docker Compose**
- **Dockerfile:**
    - Use **multi-stage builds** to reduce the final image size.
    - Run the application with a **non-root user** for enhanced security.
    - Pin the base image version (e.g., `eclipse-temurin:17-jdk-jammy`).
- **Docker Compose:** Define and run the local development environment (backend, frontend, database). The `docker-compose.yml` file must be clearly commented.

---

## 3. CI/CD Pipeline Best Practices

The pipeline revolves around building, testing, and deploying Docker images.

### **Phase 1: Continuous Integration (CI)**

**Goal:** Automatically validate code quality and package the application as a Docker image.

- **Trigger:** Activates on `push` or `pull_request` to the `develop` branch.

#### **Backend CI (`.github/workflows/ci-server.yml`)**
1.  **`checkout`**: Check out the source code.
2.  **`setup-java`**: Set up the Java environment.
3.  **`test-and-package`**: Run the full test and package lifecycle: `mvn clean verify`. This step runs Unit Tests, Integration Tests (with Testcontainers), and produces the `.jar` file.
4.  **`login-to-docker-hub`**: Log in to Docker Hub using secrets.
5.  **`build-and-push-image`**:
    - Build the Docker image from the `Dockerfile`.
    - Tag the image with `latest` and the Git SHA (e.g., `yourusername/project-backend:1.2.3-a1b2c3d`).
    - Push the image to Docker Hub.
6.  **(Optional) `code-quality-scan`**: Push reports from JaCoCo/SonarQube to a SonarCloud/SonarQube server.

#### **Frontend CI (`.github/workflows/ci-client.yml`)**
1.  **`checkout`**: Check out the source code.
2.  **`setup-node`**: Set up the Node.js environment.
3.  **`install-and-test`**: Install dependencies (`npm install`) and run linting/tests (`npm test`).
4.  **`build-static-files`**: Build static files for production: `npm run build`.

---

### **Phase 2: Continuous Deployment (CD)**

**Goal:** Automatically deploy the CI-verified application version to different environments.

#### **Backend CD (`.github/workflows/cd-server.yml`)**
- **Trigger:**
    - **Staging:** Automatically triggers on `merge` to the `develop` branch.
    - **Production:** Triggers on creating a new **tag** on the `main` branch (with a manual approval step).

- **Deployment Workflow (Staging/Production):**
    1.  **`configure-aws-credentials`**: Configure AWS access credentials.
    2.  **`get-secrets`**: Fetch environment variables and sensitive information from AWS Secrets Manager.
    3.  **`run-database-migrations`**: Run migrations using Flyway/Liquibase to update the DB schema. This can be a separate task in ECS.
    4.  **`deploy-to-ecs`**:
        - Update the **ECS Task Definition** to point to the new Docker image tag on Docker Hub.
        - Force a new deployment on the **ECS Service**. AWS will automatically handle replacing old containers with new ones based on the chosen strategy.
        - **Staging:** Use a **Rolling Update** strategy.
        - **Production:** Use a **Canary Deployment** strategy via tools like AWS CodeDeploy.
    5.  **`run-health-checks`**: Check the health check endpoint after deployment to ensure the application started successfully.

#### **Frontend CD (`.github/workflows/cd-client.yml`)**
- **Trigger:** Same as backend.
- **Deployment Workflow:**
    1.  **`configure-aws-credentials`**: Configure AWS access credentials.
    2.  **`deploy-to-s3`**: Synchronize the build directory (`dist`) to **Amazon S3**.
    3.  **`invalidate-cloudfront-cache`**: Invalidate the **Amazon CloudFront** cache to ensure users receive the latest version.

---

## 4. Infrastructure as Code (IaC) - Terraform

- **Module Structure:** Code is organized into reusable modules:
    - `modules/aws-vpc`: Virtual network.
    - `modules/aws-rds-postgres`: PostgreSQL database.
    - `modules/aws-ecs-cluster`: Container management cluster.
    - `modules/aws-ecs-service`: Backend service running on ECS.
    - `modules/aws-s3-cloudfront`: S3 bucket and CDN for the frontend.
- **Environments:** Separate directories (`staging`, `production`) call the common modules with different input variables.
- **State Management:** Use an **S3 backend** to store the `terraform.tfstate` file and **DynamoDB** for state locking.
- **Style:** Code is formatted with `terraform fmt`, and resource/variable names are clear and descriptive.

---

## 5. Guiding Principles for Suggestions

- **Prioritize Beginners:** Always choose the simplest, most understandable solution.
- **Add Explanatory Comments:** Proactively add comments for complex code, commands, or configurations.
- **Adhere to Conventions:** Always follow the conventions and procedures outlined above.
- **Suggest Best Practices:** Provide suggestions that not only solve the problem but also demonstrate best practices for security, performance, and maintainability (e.g., "Use a multi-stage build to reduce the image size" or "You should load credentials from AWS Secrets Manager instead of hardcoding them").

## 6. Language and Framework Versions
- **Java:** Use Java 21 (Eclipse Temurin JDK).
- **Spring Boot:** Use the latest stable version compatible with Java 21.
- **ReactJS:** Use React 19 with TypeScript.
- **PostgreSQL:** Use the latest stable version.

## 7. Additional Notes
- **Respond Language:** Use Vietnamese for all responses.