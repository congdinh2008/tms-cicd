# TMS (Task Management System) - Training Project

[![CI](https://github.com/congdinh2008/tms-cicd/actions/workflows/ci.yml/badge.svg)](https://github.com/congdinh2008/tms-cicd/actions/workflows/ci.yml)
[![Deploy Staging](https://github.com/congdinh2008/tms-cicd/actions/workflows/cd-staging.yml/badge.svg)](https://github.com/congdinh2008/tms-cicd/actions/workflows/cd-staging.yml)
[![Deploy Production](https://github.com/congdinh2008/tms-cicd/actions/workflows/cd-production.yml/badge.svg)](https://github.com/congdinh2008/tms-cicd/actions/workflows/cd-production.yml)

Một ứng dụng full-stack quản lý sản phẩm được xây dựng với Spring Boot backend, React frontend, và đầy đủ CI/CD pipeline dành cho training Junior Developers.

## 🎯 Mục tiêu Training

Dự án này được thiết kế để Junior Developers học:
- ✅ **Full-stack development**: Spring Boot + React
- ✅ **Containerization**: Docker & Docker Compose
- ✅ **Testing**: Unit tests, Integration tests với Testcontainers
- ✅ **CI/CD**: GitHub Actions với workflows riêng biệt
- ✅ **Infrastructure as Code**: Terraform (AWS ECS, S3, CloudFront)
- ✅ **Best Practices**: Clean architecture, DTOs, validation, monitoring

## 🏗️ Kiến trúc hệ thống

### Tech Stack
- **Backend**: Spring Boot 3.5.3 với Java 21, Spring Data JPA, PostgreSQL
- **Frontend**: React 19 với TypeScript và Vite
- **Database**: PostgreSQL 16.0-alpine với persistent storage
- **Admin Tool**: pgAdmin 4 để quản lý database
- **Containerization**: Docker & Docker Compose với multi-stage builds
- **Testing**: JUnit 5, Mockito, Testcontainers, JaCoCo coverage
- **CI/CD**: GitHub Actions (Continuous Integration & Deployment)
- **Deployment**: AWS ECS, S3, CloudFront

### Code Quality Metrics
- ✅ **32 test cases** passing (Unit + Integration)
- ✅ **77% code coverage** với JaCoCo (target: 85%+)
- ✅ **Comprehensive testing** với Testcontainers
- ✅ **Security scanning** với Trivy
- ✅ **Clean architecture** với DTOs và proper error handling

## 📁 Cấu trúc dự án

```
tms-cicd/
├── .github/workflows/          # CI/CD Pipelines
│   ├── ci.yml                 # Continuous Integration
│   ├── cd-staging.yml         # Deploy to Staging  
│   └── cd-production.yml      # Deploy to Production
├── tms-server/                # Spring Boot Backend
│   ├── src/main/java/com/congdinh/tms/
│   │   ├── TmsApplication.java          # Main application
│   │   ├── controllers/                 # REST Controllers với DTOs
│   │   │   └── ProductController.java
│   │   ├── dtos/                       # Data Transfer Objects
│   │   │   ├── ProductRequestDTO.java
│   │   │   └── ProductResponseDTO.java
│   │   ├── entities/                    # JPA Entities
│   │   │   └── Product.java
│   │   ├── exceptions/                  # Custom Exceptions
│   │   │   ├── ResourceNotFoundException.java
│   │   │   └── GlobalExceptionHandler.java
│   │   ├── mappers/                     # DTO Mappers
│   │   │   └── ProductMapper.java
│   │   ├── repositories/                # Data Access Layer
│   │   │   └── ProductRepository.java
│   │   ├── services/                    # Business Logic Layer
│   │   │   └── ProductService.java
│   │   └── config/                      # Configuration
│   │       ├── DataInitializer.java
│   │       └── DatabaseHealthCheck.java
│   ├── src/test/                       # Comprehensive Test Suite
│   │   ├── java/com/congdinh/tms/
│   │   │   ├── controllers/            # Controller Tests
│   │   │   ├── services/              # Service Tests
│   │   │   ├── mappers/               # Mapper Tests
│   │   │   └── integration/           # Integration Tests với Testcontainers
│   │   └── resources/
│   │       ├── application-test.properties
│   │       └── application-integration-test.properties
│   └── Dockerfile                      # Multi-stage build
├── tms-client/                         # React Frontend
│   ├── src/                           # React components
│   ├── package.json                   # Dependencies (simplified for CI)
│   ├── vite.config.ts                 # Vite configuration
│   └── Dockerfile                     # Frontend container
├── config/                            # Configuration files
│   └── pgadmin/
│       └── servers.json               # pgAdmin pre-configuration
├── scripts/                           # Database scripts
│   └── db-init/
│       └── 01-init.sql               # Database initialization
├── docker-compose.yml                # Development environment
├── .env.example                      # Environment template
├── Makefile                          # Development commands
├── test.sh                           # Testing script với options
├── TESTING-FIXES.md                  # CI/CD troubleshooting guide
└── README.md                         # Documentation này
```

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Java 21 (for local development)  
- Node.js 20+ (for frontend development)
- Git

### 1. Clone và setup
```bash
git clone https://github.com/congdinh2008/tms-cicd.git
cd tms-cicd

# Setup development environment
make setup
```

### 2. Development commands
```bash
# Start development environment
make dev

# Run tests
make test              # Chạy tất cả tests
make test-be           # Backend tests với coverage
make test-fe           # Frontend tests

# View coverage report
make coverage

# Other commands  
make status            # Kiểm tra service status
make logs              # Xem logs
make clean             # Dọn dẹp containers
```

### 3. Testing script
```bash
# Sử dụng test.sh script với options
./test.sh unit         # Unit tests only
./test.sh integration  # Integration tests với Testcontainers
./test.sh coverage     # Tests với coverage report
./test.sh ci           # Simulate CI pipeline
./test.sh help         # Xem all options
```

### 4. Access applications
- **Frontend**: http://localhost:2025
- **Backend API**: http://localhost:1990
- **API Documentation**: http://localhost:1990/swagger-ui.html
- **pgAdmin**: http://localhost:1999 (admin@example.com / password)
- **Health Check**: http://localhost:1990/actuator/health

## 🧪 Testing Strategy

### Backend Testing (32 test cases)
```bash
# Unit Tests (H2 database)
./mvnw test -Dspring.profiles.active=test

# Integration Tests (Testcontainers với PostgreSQL)
./mvnw verify -Dspring.profiles.active=integration-test

# Coverage Report
./mvnw jacoco:report
open target/site/jacoco/index.html
```

### Test Categories
- ✅ **Unit Tests**: ProductService, ProductController, ProductMapper
- ✅ **Integration Tests**: End-to-end API tests với Testcontainers
- ✅ **Repository Tests**: JPA repository testing
- ✅ **Validation Tests**: DTO validation và error handling
- ✅ **Security Tests**: Basic security và health checks

### Frontend Testing (Current Status)
```bash
# Current: Placeholder tests for CI compatibility
npm run test:ci        # "CI Tests passed! ✅ No tests configured yet."

# Future: Vitest setup planned
# npm test              # Vitest unit tests
# npm run test:ui       # Vitest UI mode
```

## 🔄 CI/CD Workflow

### CI Pipeline (`ci.yml`)
**Trigger**: Push/PR vào `dev` branch
```yaml
Jobs:
  - test-backend      # Unit + Integration tests, JaCoCo coverage
  - test-frontend     # Lint, build, placeholder tests  
  - security-scan     # Trivy vulnerability scanning
  - build-docker      # Build & push images to Docker Hub (dev branch only)
```

### Key CI Features
- ✅ **Java 21** với Temurin distribution
- ✅ **Testcontainers** cho integration tests
- ✅ **Docker Hub** image registry
- ✅ **Security scanning** với Trivy
- ✅ **Coverage reports** với JaCoCo
- ✅ **Frontend build** với TypeScript

### Branch Strategy
```
dev → main → production
 ↓      ↓         ↓
CI   Staging   Production
```

## 🔧 Development

### Backend Development
```bash
cd tms-server

# Run locally với H2 (fastest)
./mvnw spring-boot:run -Dspring.profiles.active=test

# Run với PostgreSQL container
docker-compose up -d tms-db
./mvnw spring-boot:run

# Run integration tests
./mvnw verify -Dspring.profiles.active=integration-test
```

### Frontend Development  
```bash
cd tms-client

# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Run linting
npm run lint
```

### Database Management
```bash
# Access pgAdmin
open http://localhost:1999

# Direct PostgreSQL access
docker-compose exec tms-db psql -U postgres -d tms_db

# Check database health
make test-db
```

## 📊 API Documentation

### Product Management API

#### GET /api/products
Lấy danh sách tất cả sản phẩm
```json
[
  {
    "id": 1,
    "name": "Laptop Dell XPS",
    "description": "High-performance laptop",
    "price": 1500.00
  }
]
```

#### POST /api/products
Tạo sản phẩm mới
```json
{
  "name": "MacBook Pro", 
  "description": "Apple laptop",
  "price": 2500.00
}
```

#### GET /api/products/{id}
Lấy thông tin sản phẩm theo ID

#### PUT /api/products/{id}
Cập nhật sản phẩm

#### DELETE /api/products/{id}
Xóa sản phẩm

#### GET /api/products/search?name={query}
Tìm kiếm sản phẩm theo tên

#### GET /api/products/price-range?min={min}&max={max}
Lọc sản phẩm theo khoảng giá

## 🔐 Security & Monitoring

### Security Features
- ✅ **Trivy vulnerability scanning** trong CI pipeline
- ✅ **Input validation** với Bean Validation
- ✅ **SQL injection protection** với JPA
- ✅ **CORS configuration** cho frontend integration
- ✅ **Health checks** cho monitoring

### Monitoring & Health Checks
- ✅ **Health endpoint**: `/actuator/health`
- ✅ **Database health check**: Automatic trong startup
- ✅ **Application metrics**: Ready for Micrometer/Prometheus
- ✅ **Logging**: Structured logging với SLF4J

## 📝 Contributing

### Development Workflow
1. **Fork và clone repository**
2. **Tạo feature branch**: `git checkout -b feature/new-feature`
3. **Implement changes với tests**
4. **Run local tests**: `./test.sh ci`
5. **Commit và push**: `git push origin feature/new-feature`
6. **Tạo Pull Request vào `dev` branch**

### Code Standards
- ✅ **Java**: Follow Spring Boot conventions, use DTOs
- ✅ **React**: TypeScript, functional components, hooks
- ✅ **Testing**: Maintain >77% coverage (target 85%+)
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

# Integration tests với Docker
./mvnw verify -Dspring.profiles.active=integration-test
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

#### CI/CD Issues
- Xem [TESTING-FIXES.md](./TESTING-FIXES.md) cho detailed troubleshooting
- Check GitHub Actions logs cho specific errors

## 📞 Support

Nếu gặp vấn đề trong quá trình training:
1. Check **Troubleshooting section** trên
2. Xem **TESTING-FIXES.md** cho CI/CD issues  
3. Xem **GitHub Issues** cho known problems
4. Liên hệ trainer hoặc tạo issue mới

## 🔮 Roadmap

### Phase 1: Current (✅ Done)
- ✅ Basic CRUD API với Product entity
- ✅ Docker containerization
- ✅ CI pipeline với GitHub Actions
- ✅ Unit + Integration testing
- ✅ Code coverage với JaCoCo

### Phase 2: Planned
- [ ] Frontend testing với Vitest
- [ ] API documentation với OpenAPI/Swagger
- [ ] Database migrations với Flyway
- [ ] Staging deployment workflow
- [ ] Production deployment với blue-green

### Phase 3: Advanced
- [ ] Terraform infrastructure
- [ ] Monitoring với Prometheus/Grafana
- [ ] Load testing với JMeter
- [ ] Security enhancements
- [ ] Performance optimization

---

**Happy Coding! 🚀**

*Dự án này được thiết kế đặc biệt cho Junior Developers để học full-stack development và DevOps practices trong môi trường thực tế.*
