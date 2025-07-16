# Makefile for TMS Project - Dành cho Junior Developers
# Các lệnh thường dùng để quản lý development environment

.PHONY: help setup dev build up down logs clean restart status test coverage lint

# Default target
help:
	@echo "TMS Project - Development Commands"
	@echo "=================================="
	@echo "🏗️  Development Commands:"
	@echo "  setup     - Setup môi trường development lần đầu"
	@echo "  dev       - Start development environment"
	@echo "  build     - Build tất cả Docker images"
	@echo "  up        - Start tất cả services"
	@echo "  down      - Stop tất cả services"
	@echo "  restart   - Restart tất cả services"
	@echo ""
	@echo "🧪 Testing Commands:"
	@echo "  test      - Chạy unit tests (backend + frontend)"
	@echo "  test-be   - Chạy backend tests với coverage"
	@echo "  test-fe   - Chạy frontend tests"
	@echo "  coverage  - Xem coverage report"
	@echo ""
	@echo "🔧 Utility Commands:"
	@echo "  logs      - Xem logs của tất cả services"
	@echo "  status    - Kiểm tra trạng thái services"
	@echo "  clean     - Dọn dẹp containers và volumes"
	@echo "  lint      - Chạy linting cho cả backend và frontend"

# Setup môi trường development lần đầu
setup:
	@echo "🏗️ Setting up TMS development environment..."
	@if [ ! -f .env ]; then \
		echo "📝 Creating .env from template..."; \
		cp .env.example .env; \
		echo "⚠️  Please edit .env file với thông tin của bạn!"; \
	fi
	@echo "🔨 Building images..."
	docker-compose build
	@echo "🚀 Starting services..."
	docker-compose up -d
	@echo "✅ Development environment setup complete!"
	@echo "Frontend: http://localhost:2025"
	@echo "Backend API: http://localhost:1990"
	@echo "pgAdmin: http://localhost:1999"

# Start development environment (equivalent to up)
dev: up

# Build tất cả images
build:
	@echo "🔨 Building Docker images..."
	docker-compose build

# Start services
up:
	@echo "🚀 Starting TMS services..."
	docker-compose up -d
	@echo "✅ Services started!"
	@echo "Frontend: http://localhost:2025"
	@echo "Backend API: http://localhost:1990"
	@echo "pgAdmin: http://localhost:1999"

# Stop services
down:
	@echo "🛑 Stopping TMS services..."
	docker-compose down

# Xem logs
logs:
	@echo "📋 Viewing logs..."
	docker-compose logs -f

# Restart services
restart:
	@echo "🔄 Restarting services..."
	docker-compose restart

# Kiểm tra status
status:
	@echo "📊 Service status:"
	docker-compose ps

# Dọn dẹp
clean:
	@echo "🧹 Cleaning up..."
	docker-compose down --volumes --remove-orphans
	docker system prune -f

# Setup lần đầu
setup:
	@echo "🏗️ Setting up TMS project..."
	@if [ ! -f .env ]; then \
		echo "📝 Creating .env from template..."; \
		cp .env.example .env; \
		echo "⚠️  Please edit .env file với thông tin của bạn!"; \
	fi
	@echo "🔨 Building images..."
	docker-compose build
	@echo "🚀 Starting services..."
	docker-compose up -d
	@echo "✅ Setup complete!"

# Chạy unit tests cho cả backend và frontend
test:
	@echo "🧪 Running tests..."
	@echo "Backend tests (với H2 database):"
	cd tms-server && ./mvnw clean test -Dspring.profiles.active=test
	@echo "Frontend tests:"
	cd tms-client && npm test

# Chạy backend tests với coverage report
test-be:
	@echo "🧪 Running backend tests với coverage..."
	cd tms-server && ./mvnw clean verify -Dspring.profiles.active=test
	@echo "✅ Coverage report generated: tms-server/target/site/jacoco/index.html"

# Chạy frontend tests
test-fe:
	@echo "🧪 Running frontend tests..."
	cd tms-client && npm test

# Xem coverage report
coverage:
	@echo "📊 Opening coverage report..."
	@if [ -f tms-server/target/site/jacoco/index.html ]; then \
		open tms-server/target/site/jacoco/index.html; \
	else \
		echo "⚠️  Coverage report not found. Run 'make test-be' first!"; \
	fi

# Chạy linting
lint:
	@echo "🔍 Running linting..."
	@echo "Backend linting (checkstyle):"
	cd tms-server && ./mvnw checkstyle:check
	@echo "Frontend linting:"
	cd tms-client && npm run lint

# Build chỉ backend để test nhanh
build-server:
	@echo "🔨 Building server only..."
	cd tms-server && ./mvnw clean package -DskipTests

# Test database connection
test-db:
	@echo "🔍 Testing database connection..."
	docker-compose exec tms-db pg_isready -U tms_user -d tms_db || echo "⚠️  Database not ready or not running"
