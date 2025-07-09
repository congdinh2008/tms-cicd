# TMS (Task Management System)

A full-stack task management application built with Spring Boot backend and React frontend, containerized with Docker.

## 🏗️ Architecture

- **Backend**: Spring Boot 3.5.3 with Java 21
- **Frontend**: React 19 with TypeScript and Vite
- **Database**: PostgreSQL 16.0
- **Admin Panel**: pgAdmin 4
- **Containerization**: Docker & Docker Compose
- **CI/CD**: GitHub Actions with AWS EC2 deployment
- **Infrastructure**: Terraform (AWS VPC, EC2, CloudWatch)

## 📁 Project Structure

```
tms-cicd/
├── tms-server/          # Spring Boot backend
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── com/congdinh/tms/
│   │   │   │       ├── TmsApplication.java
│   │   │   │       ├── controllers/
│   │   │   │       │   └── ProductController.java
│   │   │   │       └── entities/
│   │   │   │           └── Product.java
│   │   │   └── resources/
│   │   │       └── application.properties
│   │   └── test/
│   ├── pom.xml
│   └── Dockerfile
├── tms-client/          # React frontend
│   ├── src/
│   │   ├── App.tsx
│   │   ├── main.tsx
│   │   └── ...
│   ├── package.json
│   └── Dockerfile
├── deployment/          # CI/CD and Infrastructure
│   ├── cicd/           # GitHub Actions workflows
│   │   ├── tms-server-ci.yml
│   │   ├── tms-server-cd.yml
│   │   ├── tms-client-ci.yml
│   │   └── tms-client-cd.yml
│   ├── terraform/      # Infrastructure as Code
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── ec2.tf
│   │   └── scripts/
│   ├── deploy.sh       # Deployment script
│   └── README.md       # Deployment guide
├── .github/workflows/  # GitHub Actions
├── docker-compose.yml
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- Java 21 (for local development)
- Node.js 24+ (for local development)
- AWS CLI (for deployment)
- Terraform (for infrastructure)

### Using Docker Compose (Recommended)

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tms-cicd
   ```

2. **Start all services**
   ```bash
   docker-compose up -d
   ```

3. **Access the applications**
   - Frontend: http://localhost:2025
   - Backend API: http://localhost:1990
   - pgAdmin: http://localhost:1999

### Local Development

#### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd tms-server
   ```

2. **Run with Maven**
   ```bash
   ./mvnw spring-boot:run
   ```

3. **Or build and run JAR**
   ```bash
   ./mvnw clean package
   java -jar target/tms-0.0.1-SNAPSHOT.jar
   ```

#### Frontend Setup

1. **Navigate to frontend directory**
   ```bash
   cd tms-client
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start development server**
   ```bash
   npm run dev
   ```

4. **Build for production**
   ```bash
   npm run build
   ```

## 📊 Services Overview

### Backend (tms-server)
- **Port**: 1990 (Docker) / 8080 (Local)
- **Technology**: Spring Boot 3.5.3, Java 21
- **Features**: REST API, Product management

### Frontend (tms-client)
- **Port**: 2025 (Docker) / 5173 (Local Dev)
- **Technology**: React 19, TypeScript, Vite
- **Features**: Modern React UI with TypeScript

### Database (PostgreSQL)
- **Port**: 5432
- **Database**: tms_db
- **Username**: postgres
- **Password**: postgres

### pgAdmin
- **Port**: 1999
- **Email**: congdinh2021@gmail.com
- **Password**: congdinh2021

## 🔌 API Endpoints

### Products API

#### GET /api/products
Returns a list of all products.

**Response:**
```json
[
  {
    "id": "1",
    "name": "Product A",
    "description": "Description for Product A",
    "price": 10.99
  },
  {
    "id": "2",
    "name": "Product B",
    "description": "Description for Product B",
    "price": 12.99
  }
]
```

## 🛠️ Development

### Backend Development

- **Framework**: Spring Boot 3.5.3
- **Java Version**: 21
- **Build Tool**: Maven
- **Dev Tools**: Spring Boot DevTools for hot reload

### Frontend Development

- **Framework**: React 19
- **Language**: TypeScript
- **Build Tool**: Vite
- **Linting**: ESLint with TypeScript rules

### Testing

#### Backend Tests
```bash
cd tms-server
./mvnw test
```

#### Frontend Tests
```bash
cd tms-client
npm test
```

## 🐳 Docker Commands

### Build and run all services
```bash
docker-compose up --build
```

### Stop all services
```bash
docker-compose down
```

### View logs
```bash
docker-compose logs -f [service-name]
```

### Rebuild specific service
```bash
docker-compose up --build [service-name]
```

## 🔧 Configuration

### Backend Configuration
Configuration is managed through `application.properties`:
```properties
spring.application.name=tms
```

### Frontend Configuration
Configuration is managed through `vite.config.ts`:
```typescript
export default defineConfig({
  server: {
    host: '0.0.0.0',
    port: 2025,
  },
  plugins: [react()],
})
```

## 📝 Scripts

### Backend Scripts
```bash
# Run application
./mvnw spring-boot:run

# Run tests
./mvnw test

# Package application
./mvnw clean package

# Skip tests during build
./mvnw clean package -DskipTests
```

### Frontend Scripts
```bash
# Development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Lint code
npm run lint
```

## 🌐 Environment Variables

### Docker Compose Environment
- `POSTGRES_USER`: Database username
- `POSTGRES_PASSWORD`: Database password
- `POSTGRES_DB`: Database name
- `PGADMIN_DEFAULT_EMAIL`: pgAdmin login email
- `PGADMIN_DEFAULT_PASSWORD`: pgAdmin login password

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Troubleshooting

### Common Issues

1. **Port already in use**
   - Check if ports 1990, 2025, 5432, or 1999 are already in use
   - Modify ports in `docker-compose.yml` if needed

2. **Database connection issues**
   - Ensure PostgreSQL container is running
   - Check database credentials in configuration

3. **Frontend build issues**
   - Clear node_modules and reinstall dependencies
   - Check Node.js version compatibility

4. **SSH Connection Issues (Production)**
   ```bash
   # If SSH key has passphrase, use ssh-agent to cache it
   ssh-add ~/.ssh/tms-key
   ssh ec2-user@<instance-ip>
   
   # Or connect without caching passphrase (will prompt each time)
   ssh -i ~/.ssh/tms-key ec2-user@<instance-ip>
   
   # Alternative: Use AWS SSM (no SSH key needed)
   aws ssm start-session --target <instance-id>
   ```

5. **CI/CD Pipeline Issues**
   - Check GitHub Actions logs
   - Verify GitHub Secrets are properly set
   - Ensure Docker Hub credentials are correct

### SSH Key Management

**If you have SSH passphrase:**
- ✅ **More secure**: Passphrase protects private key
- ⚠️ **Manual entry**: Need to enter passphrase for each SSH connection
- 💡 **Use ssh-agent**: Cache passphrase to avoid repeated entry
- 🔄 **CI/CD not affected**: Pipeline uses AWS SSM, not SSH

**Commands for SSH with passphrase:**
```bash
# Add key to ssh-agent (cache passphrase)
ssh-add ~/.ssh/tms-key

# SSH with cached key
ssh ec2-user@<instance-ip>

# Alternative: AWS SSM (recommended)
aws ssm start-session --target <instance-id>
```

### Useful Commands

```bash
# Check running containers
docker ps

# View container logs
docker logs [container-name]

# Access database directly
docker exec -it postgres_container psql -U postgres -d tms_db

# Clean up Docker resources
docker system prune -a
```

## 📞 Support

For support and questions, please contact the development team.

## 🔄 CI/CD Pipeline

### Development Workflow
1. **Local Development**: Docker Compose for quick setup
2. **CI Pipeline**: Automated testing, building, and security scanning
3. **CD Pipeline**: Automated deployment to AWS EC2
4. **Monitoring**: CloudWatch metrics and logs

### Pipeline Features
- **Automated Testing**: Unit tests, integration tests
- **Security Scanning**: Container vulnerability scanning with Trivy
- **Quality Gates**: ESLint, TypeScript checking
- **Docker Registry**: Push to Docker Hub
- **Blue-Green Deployment**: Zero-downtime deployments
- **Rollback**: Automatic rollback on failure
- **Monitoring**: Health checks and performance tests

### Deployment Options

#### 1. Local Development (Docker Compose)
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

#### 2. Production Deployment (AWS EC2)
```bash
# Deploy infrastructure
cd deployment
./deploy.sh

# Configure GitHub Secrets and push code
# CI/CD pipeline will handle the rest
```

For detailed deployment instructions, see [deployment/README.md](deployment/README.md)
