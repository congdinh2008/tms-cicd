#!/bin/bash

# TMS Testing Script
# Cung cấp các options để chạy different types of tests

set -e

echo "🚀 TMS Testing Script"
echo "===================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Function to run unit tests
run_unit_tests() {
    print_status "Running unit tests..."
    cd tms-server
    mvn clean test -Dtest="!*IntegrationTest,!*IT"
    cd ..
}

# Function to run integration tests
run_integration_tests() {
    print_status "Running integration tests with Testcontainers..."
    check_docker
    cd tms-server
    mvn clean test -Dtest="*IntegrationTest,*IT"
    cd ..
}

# Function to run all tests
run_all_tests() {
    print_status "Running all tests..."
    check_docker
    cd tms-server
    mvn clean verify
    cd ..
}

# Function to generate coverage report
generate_coverage() {
    print_status "Generating code coverage report..."
    cd tms-server
    mvn clean test jacoco:report
    print_status "Coverage report generated at: tms-server/target/site/jacoco/index.html"
    cd ..
}

# Function to run tests with coverage
run_tests_with_coverage() {
    print_status "Running tests with coverage analysis..."
    check_docker
    cd tms-server
    mvn clean verify jacoco:report
    print_status "Coverage report available at: target/site/jacoco/index.html"
    
    # Try to open coverage report
    if command -v open >/dev/null 2>&1; then
        print_status "Opening coverage report..."
        open target/site/jacoco/index.html
    elif command -v xdg-open >/dev/null 2>&1; then
        print_status "Opening coverage report..."
        xdg-open target/site/jacoco/index.html
    fi
    cd ..
}

# Function to lint and format code
lint_code() {
    print_status "Running code quality checks..."
    cd tms-server
    mvn spotless:check || {
        print_warning "Code formatting issues found. Running formatter..."
        mvn spotless:apply
    }
    cd ..
}

# Function to start test environment
start_test_env() {
    print_status "Starting test environment..."
    check_docker
    docker-compose up -d tms-db
    print_status "PostgreSQL database started. Waiting for it to be ready..."
    sleep 10
    print_status "Test environment ready!"
}

# Function to stop test environment
stop_test_env() {
    print_status "Stopping test environment..."
    docker-compose down
    print_status "Test environment stopped."
}

# Function to run CI simulation
simulate_ci() {
    print_status "Simulating CI pipeline..."
    
    print_status "Step 1: Code quality checks"
    lint_code
    
    print_status "Step 2: Unit tests"
    run_unit_tests
    
    print_status "Step 3: Integration tests"
    run_integration_tests
    
    print_status "Step 4: Coverage analysis"
    generate_coverage
    
    print_status "✅ CI simulation completed successfully!"
}

# Function to show help
show_help() {
    echo "Usage: ./test.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  unit                 Run unit tests only"
    echo "  integration          Run integration tests only"
    echo "  all                  Run all tests"
    echo "  coverage             Run tests with coverage report"
    echo "  lint                 Run code quality checks"
    echo "  start-env            Start test environment (PostgreSQL)"
    echo "  stop-env             Stop test environment"
    echo "  ci                   Simulate CI pipeline"
    echo "  help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./test.sh unit       # Run only unit tests"
    echo "  ./test.sh coverage   # Run tests with coverage"
    echo "  ./test.sh ci         # Full CI simulation"
}

# Main script logic
case "${1:-help}" in
    "unit")
        run_unit_tests
        ;;
    "integration")
        run_integration_tests
        ;;
    "all")
        run_all_tests
        ;;
    "coverage")
        run_tests_with_coverage
        ;;
    "lint")
        lint_code
        ;;
    "start-env")
        start_test_env
        ;;
    "stop-env")
        stop_test_env
        ;;
    "ci")
        simulate_ci
        ;;
    "help"|*)
        show_help
        ;;
esac

print_status "Done! 🎉"
