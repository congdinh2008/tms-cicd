# TMS (Task Management System) - Training Project[![CI](https://github.com/USERNAME/tms-cicd/actions/workflows/ci.yml/badge.svg)](https://github.com/USERNAME/tms-cicd/actions/workflows/ci.yml)[![Deploy Staging](https://github.com/USERNAME/tms-cicd/actions/workflows/cd-staging.yml/badge.svg)](https://github.com/USERNAME/tms-cicd/actions/workflows/cd-staging.yml)[![Deploy Production](https://github.com/USERNAME/tms-cicd/actions/workflows/cd-production.yml/badge.svg)](https://github.com/USERNAME/tms-cicd/actions/workflows/cd-production.yml)Một ứng dụng full-stack quản lý sản phẩm được xây dựng với Spring Boot backend, React frontend, và đầy đủ CI/CD pipeline dành cho training Junior Developers.## 🎯 Mục tiêu TrainingDự án này được thiết kế để Junior Developers học:- ✅ **Full-stack development**: Spring Boot + React- ✅ **Containerization**: Docker & Docker Compose- ✅ **Testing**: Unit tests, Integration tests với Testcontainers- ✅ **CI/CD**: GitHub Actions với 3 workflow riêng biệt- ✅ **Infrastructure as Code**: Terraform (AWS ECS, S3, CloudFront)- ✅ **Best Practices**: Clean architecture, DTOs, validation, monitoring## 🏗️ Kiến trúc hệ thống### Tech Stack- **Backend**: Spring Boot 3.5.3 với Java 21, Spring Data JPA, PostgreSQL- **Frontend**: React 19 với TypeScript và Vite- **Database**: PostgreSQL 16.0-alpine với persistent storage- **Admin Tool**: pgAdmin 4 để quản lý database- **Containerization**: Docker & Docker Compose với multi-stage builds- **Testing**: JUnit 5, Mockito, Testcontainers, JaCoCo coverage- **CI/CD**: GitHub Actions (3 separate workflows)- **Deployment**: AWS ECS, S3, CloudFront### Code Quality Metrics- ✅ **32 test cases** passing (Unit + Integration)- ✅ **>85% code coverage** với JaCoCo- ✅ **Comprehensive testing** với Testcontainers- ✅ **Security scanning** với Trivy- ✅ **Clean architecture** với DTOs và proper error handling## 📁 Cấu trúc dự án```tms-cicd/├── .github/workflows/          # CI/CD Pipelines│   ├── ci.yml                 # Continuous Integration│   ├── cd-staging.yml         # Deploy to Staging│   └── cd-production.yml      # Deploy to Production├── tms-server/                # Spring Boot Backend│   ├── src/main/java/com/congdinh/tms/│   │   ├── TmsApplication.java          # Main application│   │   ├── controllers/                 # REST Controllers với DTOs│   │   │   └── ProductController.java│   │   ├── dtos/                       # Data Transfer Objects│   │   │   ├── ProductDto.java│   │   │   └── CreateProductDto.java│   │   ├── entities/                    # JPA Entities│   │   │   └── Product.java│   │   ├── exceptions/                  # Custom Exceptions│   │   │   ├── ResourceNotFoundException.java│   │   │   └── GlobalExceptionHandler.java│   │   ├── mappers/                     # DTO Mappers│   │   │   └── ProductMapper.java│   │   ├── repositories/                # Data Access Layer│   │   │   └── ProductRepository.java│   │   ├── services/                    # Business Logic Layer│   │   │   └── ProductService.java│   │   └── config/                      # Configuration│   │       ├── DataInitializer.java│   │       └── DatabaseHealthCheck.java│   ├── src/test/                       # Comprehensive Test Suite│   │   ├── java/com/congdinh/tms/│   │   │   ├── controllers/            # Controller Tests│   │   │   ├── services/              # Service Tests│   │   │   └── integration/           # Integration Tests với Testcontainers│   │   └── resources/│   │       └── application-test.properties│   └── Dockerfile                      # Multi-stage build├── tms-client/                         # React Frontend│   ├── src/                           # React components│   ├── package.json                   # Dependencies│   └── Dockerfile                     # Frontend container├── config/                            # Configuration files│   └── pgadmin/│       └── servers.json               # pgAdmin pre-configuration├── scripts/                           # Database scripts│   └── db-init/│       └── 01-init.sql               # Database initialization├── docker-compose.yml                # Development environment├── .env.example                      # Environment template├── Makefile                          # Development commands└── README.md                         # Documentation```## 🚀 Quick Start### Prerequisites- Docker & Docker Compose- Java 21 (for local development)- Node.js 20+ (for frontend development)- Git### 1. Clone và setup```bashgit clone <repository-url>cd tms-cicd# Setup development environmentmake setup```### 2. Development commands```bash# Start development environmentmake dev# Run testsmake test              # Chạy tất cả testsmake test-be           # Backend tests với coveragemake test-fe           # Frontend tests# View coverage reportmake coverage# Other commandsmake status            # Kiểm tra service statusmake logs              # Xem logsmake clean             # Dọn dẹp containers```### 3. Access applications- **Frontend**: http://localhost:2025- **Backend API**: http://localhost:1990- **API Documentation**: http://localhost:1990/swagger-ui.html- **pgAdmin**: http://localhost:1999 (admin@admin.com / admin)- **Health Check**: http://localhost:1990/health## 🧪 Testing Strategy### Backend Testing (32 test cases)```bash# Unit Tests (H2 database)./mvnw test -Dspring.profiles.active=test# Integration Tests (Testcontainers với PostgreSQL)./mvnw verify -Dspring.profiles.active=test# Coverage Report./mvnw jacoco:reportopen target/site/jacoco/index.html```### Test Categories- ✅ **Unit Tests**: ProductService, ProductController- ✅ **Integration Tests**: End-to-end API tests với Testcontainers- ✅ **Repository Tests**: JPA repository testing- ✅ **Validation Tests**: DTO validation và error handling- ✅ **Security Tests**: Basic security và health checks## 🔄 CI/CD Workflow### 3 Separate Workflows#### 1. CI Pipeline (`ci.yml`)**Trigger**: Push/PR vào `develop` branch```yamlJobs:  - test-backend      # Unit + Integration tests, JaCoCo coverage  - test-frontend     # Lint, test, build  - security-scan     # Trivy vulnerability scanning  - build-docker      # Build & push images to Docker Hub```#### 2. Staging Deployment (`cd-staging.yml`)**Trigger**: Push vào `main` branch```yamlJobs:  - deploy-staging    # Deploy to AWS ECS Staging                     # Database migrations                     # Smoke tests                     # S3 + CloudFront deployment```#### 3. Production Deployment (`cd-production.yml`)**Trigger**: Manual with approval gate```yamlJobs:  - validate-input    # Confirm deployment  - deploy-production # Blue-Green deployment                     # Production health checks                     # Rollback capability```### Branch Strategy```develop → main → production   ↓        ↓         ↓  CI    Staging   Production```## 🔧 Development### Backend Development```bashcd tms-server# Run locally với H2./mvnw spring-boot:run -Dspring.profiles.active=test# Run với PostgreSQL containerdocker-compose up -d tms-db./mvnw spring-boot:run```### Frontend Development```bashcd tms-client# Install dependenciesnpm install# Start development servernpm run dev# Run testsnpm test# Build for productionnpm run build```### Database Management```bash# Access pgAdminopen http://localhost:1999# Direct PostgreSQL accessdocker-compose exec tms-db psql -U tms_user -d tms_db# Run migrationsmake build-server  # Build application với Flyway migrations```## 📊 API Documentation### Product Management API#### GET /api/productsLấy danh sách tất cả sản phẩm```json[  {    "id": 1,    "name": "Laptop Dell XPS",    "description": "High-performance laptop",    "price": 1500.00,    "category": "Electronics"  }]```#### POST /api/productsTạo sản phẩm mới```json{  "name": "MacBook Pro",  "description": "Apple laptop",  "price": 2500.00,  "category": "Electronics"}```#### GET /api/products/{id}Lấy thông tin sản phẩm theo ID#### PUT /api/products/{id}Cập nhật sản phẩm#### DELETE /api/products/{id}Xóa sản phẩm#### GET /api/products/search?query={query}Tìm kiếm sản phẩm theo tên## 🔐 Security & Monitoring### Security Features- ✅ **Trivy vulnerability scanning** trong CI pipeline- ✅ **HTTPS only** trong production- ✅ **Input validation** với Bean Validation- ✅ **SQL injection protection** với JPA- ✅ **CORS configuration** cho frontend integration### Monitoring & Health Checks- ✅ **Health endpoint**: `/health`- ✅ **Database health check**: Automatic trong startup- ✅ **Application metrics**: Ready for Micrometer/Prometheus- ✅ **Logging**: Structured logging với SLF4J## 🏗️ Infrastructure (Production)### AWS Architecture```Internet → CloudFront → S3 (Frontend)                     ↓Internet → ALB → ECS Fargate (Backend) → RDS PostgreSQL```### Terraform Modules- `modules/aws-vpc`: Network infrastructure- `modules/aws-rds-postgres`: Database- `modules/aws-ecs-cluster`: Container orchestration- `modules/aws-s3-cloudfront`: Frontend hosting## 📝 Contributing### Development Workflow1. **Fork và clone repository**2. **Tạo feature branch**: `git checkout -b feature/new-feature`3. **Implement changes với tests**4. **Run local tests**: `make test`
5. **Commit và push**: `git push origin feature/new-feature`
6. **Tạo Pull Request vào `develop` branch**

### Code Standards
- ✅ **Java**: Follow Spring Boot conventions, use DTOs
- ✅ **React**: TypeScript, functional components, hooks
- ✅ **Testing**: Maintain >85% coverage
- ✅ **Documentation**: Update README cho changes

## 🚨 Troubleshooting

### Common Issues

#### Database Connection Issues
```bash
# Check database status
make status
make test-db

# Restart database
docker-compose restart tms-db
```

#### Test Failures
```bash
# Clean và rebuild
make clean
make build

# Run specific test
cd tms-server
./mvnw test -Dtest=ProductServiceTest
```

#### Docker Issues
```bash
# Clean Docker system
make clean
docker system prune -a

# Rebuild từ scratch
make build
make up
```

## 📞 Support

Nếu gặp vấn đề trong quá trình training:
1. Check **Troubleshooting section** trên
2. Xem **GitHub Issues** cho known problems
3. Liên hệ trainer hoặc tạo issue mới

---

**Happy Coding! 🚀**

*Dự án này được thiết kế đặc biệt cho Junior Developers để học full-stack development và DevOps practices trong môi trường thực tế.*
