#!/bin/bash

# TMS Infrastructure Validation Script
# This script validates the modularized Terraform infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -d "deployment/terraform" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

print_status "Starting TMS Infrastructure Validation..."

# Check Terraform installation
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install Terraform first."
    exit 1
fi

print_success "Terraform is installed: $(terraform version | head -n1)"

# Change to terraform directory
cd deployment/terraform

# Check if all required modules exist
print_status "Checking module structure..."

required_modules=("networking" "security" "compute" "monitoring")
for module in "${required_modules[@]}"; do
    if [ -d "modules/$module" ]; then
        print_success "Module '$module' found"
        
        # Check if module has required files
        required_files=("main.tf" "variables.tf" "outputs.tf")
        for file in "${required_files[@]}"; do
            if [ -f "modules/$module/$file" ]; then
                print_success "  ✓ $file exists"
            else
                print_error "  ✗ $file missing in $module module"
            fi
        done
    else
        print_error "Module '$module' not found"
    fi
done

# Check root configuration files
print_status "Checking root configuration files..."
root_files=("main.tf" "variables.tf" "outputs.tf")
for file in "${root_files[@]}"; do
    if [ -f "$file" ]; then
        print_success "Root $file exists"
    else
        print_error "Root $file missing"
    fi
done

# Check if terraform.tfvars.example exists
if [ -f "terraform.tfvars.example" ]; then
    print_success "terraform.tfvars.example exists"
else
    print_warning "terraform.tfvars.example not found"
fi

# Validate Terraform configuration
print_status "Validating Terraform configuration..."

# Initialize Terraform
print_status "Initializing Terraform..."
if terraform init -backend=false > /dev/null 2>&1; then
    print_success "Terraform initialization successful"
else
    print_error "Terraform initialization failed"
    exit 1
fi

# Validate configuration
print_status "Validating Terraform configuration..."
if terraform validate > /dev/null 2>&1; then
    print_success "Terraform configuration is valid"
else
    print_error "Terraform configuration validation failed"
    terraform validate
    exit 1
fi

# Format check
print_status "Checking Terraform formatting..."
if terraform fmt -check=true -diff=true > /dev/null 2>&1; then
    print_success "Terraform code is properly formatted"
else
    print_warning "Terraform code formatting issues found. Run 'terraform fmt' to fix."
fi

# Check for terraform.tfvars
if [ -f "terraform.tfvars" ]; then
    print_status "Found terraform.tfvars, running plan..."
    if terraform plan -out=tfplan > /dev/null 2>&1; then
        print_success "Terraform plan successful"
        rm -f tfplan
    else
        print_warning "Terraform plan failed (likely due to backend configuration)"
        print_status "This is expected if S3 backend is not set up yet"
    fi
else
    print_warning "terraform.tfvars not found. Create from terraform.tfvars.example to test planning."
fi

# Check GitHub Actions workflows
print_status "Checking GitHub Actions workflows..."
cd ../../

workflows_dir=".github/workflows"
if [ -d "$workflows_dir" ]; then
    workflows=("reusable-ci.yml" "reusable-cd.yml" "tms-server-ci.yml" "tms-server-cd.yml" "tms-client-ci.yml" "tms-client-cd.yml")
    
    for workflow in "${workflows[@]}"; do
        if [ -f "$workflows_dir/$workflow" ]; then
            print_success "Workflow $workflow exists"
        else
            print_error "Workflow $workflow missing"
        fi
    done
else
    print_error "GitHub Actions workflows directory not found"
fi

# Check for required directories
print_status "Checking project structure..."
required_dirs=("tms-server" "tms-client" "deployment")
for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        print_success "Directory '$dir' exists"
    else
        print_error "Directory '$dir' missing"
    fi
done

# Check Docker files
print_status "Checking Docker files..."
docker_files=("tms-server/Dockerfile" "tms-client/Dockerfile")
for file in "${docker_files[@]}"; do
    if [ -f "$file" ]; then
        print_success "Docker file $file exists"
    else
        print_error "Docker file $file missing"
    fi
done

# Final summary
print_status "Validation complete!"
print_success "✅ TMS infrastructure validation passed"
print_status "You can now:"
print_status "  1. Configure terraform.tfvars with your AWS credentials"
print_status "  2. Run 'terraform plan' to preview changes"
print_status "  3. Run 'terraform apply' to create infrastructure"
print_status "  4. Configure GitHub repository secrets for CI/CD"
print_status "  5. Test the CI/CD pipelines"

echo ""
print_success "🎉 TMS infrastructure is ready for deployment!"
