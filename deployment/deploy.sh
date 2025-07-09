#!/bin/bash
# Deployment script for TMS infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists terraform; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    if ! command_exists aws; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        print_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    print_success "All prerequisites met!"
}

# Function to generate SSH key if not exists
generate_ssh_key() {
    local key_path="$HOME/.ssh/tms-key"
    
    if [ ! -f "$key_path" ]; then
        print_status "Generating SSH key pair..."
        print_warning "Choose SSH key security option:"
        print_warning "1. Generate key WITH passphrase (more secure, requires passphrase for manual SSH)"
        print_warning "2. Generate key WITHOUT passphrase (less secure, easier for automation)"
        
        read -p "Enter choice (1 or 2): " -n 1 -r choice
        echo
        
        case $choice in
            1)
                print_status "Generating SSH key with passphrase..."
                ssh-keygen -t rsa -b 4096 -f "$key_path" -q
                print_success "SSH key pair generated with passphrase at $key_path"
                print_warning "Note: You'll need to enter passphrase when SSH manually to instances"
                print_warning "CI/CD pipeline uses AWS SSM, so passphrase won't affect automation"
                ;;
            2)
                print_status "Generating SSH key without passphrase..."
                ssh-keygen -t rsa -b 4096 -f "$key_path" -N "" -q
                print_success "SSH key pair generated without passphrase at $key_path"
                print_warning "Consider using ssh-agent or AWS SSM for better security"
                ;;
            *)
                print_warning "Invalid choice, generating with passphrase as default..."
                ssh-keygen -t rsa -b 4096 -f "$key_path" -q
                print_success "SSH key pair generated with passphrase at $key_path"
                ;;
        esac
    else
        print_warning "SSH key already exists at $key_path"
        # Check if key has passphrase
        if ssh-keygen -y -f "$key_path" -P "" >/dev/null 2>&1; then
            print_status "SSH key does NOT have a passphrase"
        else
            print_status "SSH key has a passphrase"
            print_warning "You'll need passphrase for manual SSH connections"
            print_warning "Consider using: ssh-add ~/.ssh/tms-key (to cache passphrase)"
            print_warning "Or use AWS SSM: aws ssm start-session --target <instance-id>"
        fi
    fi
}

# Function to setup terraform variables
setup_terraform_vars() {
    local terraform_dir="$1"
    local tfvars_file="$terraform_dir/terraform.tfvars"
    
    if [ ! -f "$tfvars_file" ]; then
        print_status "Creating terraform.tfvars file..."
        cp "$terraform_dir/terraform.tfvars.example" "$tfvars_file"
        
        # Get SSH public key
        local ssh_key_path="$HOME/.ssh/tms-key.pub"
        if [ -f "$ssh_key_path" ]; then
            local public_key=$(cat "$ssh_key_path")
            # Escape special characters for sed
            public_key=$(echo "$public_key" | sed 's/[[\.*^$()+?{|]/\\&/g')
            
            # Update terraform.tfvars with SSH public key
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                sed -i '' "s|public_key_material = \"\"|public_key_material = \"$public_key\"|" "$tfvars_file"
            else
                # Linux
                sed -i "s|public_key_material = \"\"|public_key_material = \"$public_key\"|" "$tfvars_file"
            fi
        fi
        
        print_warning "Please edit $tfvars_file and configure:"
        print_warning "  - dockerhub_username"
        print_warning "  - allowed_ssh_cidr (for better security)"
        print_warning "  - any other customizations you need"
        
        read -p "Press Enter to continue after editing terraform.tfvars..."
    else
        print_success "terraform.tfvars already exists"
    fi
}

# Function to deploy infrastructure
deploy_infrastructure() {
    local terraform_dir="$1"
    
    print_status "Initializing Terraform..."
    cd "$terraform_dir"
    terraform init
    
    print_status "Planning infrastructure deployment..."
    terraform plan
    
    read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Applying infrastructure changes..."
        terraform apply -auto-approve
        
        print_success "Infrastructure deployed successfully!"
        
        # Show outputs
        print_status "Deployment information:"
        terraform output
        
        # Save important outputs to file
        terraform output -json > deployment-outputs.json
        print_status "Deployment outputs saved to deployment-outputs.json"
        
    else
        print_warning "Deployment cancelled by user"
        exit 0
    fi
}

# Function to setup GitHub secrets
setup_github_secrets() {
    local terraform_dir="$1"
    
    # Change to terraform directory to check for outputs
    local current_dir=$(pwd)
    cd "$terraform_dir"
    
    if [ ! -f "deployment-outputs.json" ]; then
        print_error "deployment-outputs.json not found. Please run deployment first."
        cd "$current_dir"
        return 1
    fi
    
    print_status "GitHub Secrets Setup Instructions:"
    print_status "=================================="
    
    # Extract values from terraform output
    local server_instance_id=$(cat "deployment-outputs.json" | jq -r '.server_instance_id.value // empty')
    local client_instance_id=$(cat "deployment-outputs.json" | jq -r '.client_instance_id.value // empty')
    local aws_region=$(cat "deployment-outputs.json" | jq -r '.deployment_info.value.region // "ap-southeast-1"')
    
    echo ""
    print_status "Add these secrets to your GitHub repository:"
    echo ""
    echo "Repository Settings > Secrets and variables > Actions > New repository secret"
    echo ""
    echo "Required secrets:"
    echo "=================="
    echo "DOCKERHUB_USERNAME=your-dockerhub-username"
    echo "DOCKERHUB_TOKEN=your-dockerhub-token"
    echo "AWS_ACCESS_KEY_ID=your-aws-access-key"
    echo "AWS_SECRET_ACCESS_KEY=your-aws-secret-key"
    
    if [ ! -z "$server_instance_id" ]; then
        echo "EC2_SERVER_INSTANCE_ID=$server_instance_id"
    fi
    
    if [ ! -z "$client_instance_id" ]; then
        echo "EC2_CLIENT_INSTANCE_ID=$client_instance_id"
    fi
    
    echo ""
    echo "Optional secrets:"
    echo "=================="
    echo "SLACK_WEBHOOK=your-slack-webhook-url"
    echo "CLOUDFRONT_DISTRIBUTION_ID=your-cloudfront-id"
    echo ""
    
    # Restore original directory
    cd "$current_dir"
}

# Function to validate deployment
validate_deployment() {
    local terraform_dir="$1"
    
    # Change to terraform directory to check for outputs
    local current_dir=$(pwd)
    cd "$terraform_dir"
    
    if [ ! -f "deployment-outputs.json" ]; then
        print_error "deployment-outputs.json not found. Cannot validate deployment."
        cd "$current_dir"
        return 1
    fi
    
    print_status "Validating deployment..."
    
    # Get server and client IPs
    local server_ip=$(cat "deployment-outputs.json" | jq -r '.server_public_ip.value // empty')
    local client_ip=$(cat "deployment-outputs.json" | jq -r '.client_public_ip.value // empty')
    
    if [ ! -z "$server_ip" ]; then
        print_status "Testing server connectivity..."
        if curl -s --connect-timeout 10 "http://$server_ip:8080/actuator/health" >/dev/null; then
            print_success "Server is accessible at http://$server_ip:8080"
        else
            print_warning "Server health check failed. This is normal if application is not deployed yet."
        fi
    fi
    
    if [ ! -z "$client_ip" ]; then
        print_status "Testing client connectivity..."
        if curl -s --connect-timeout 10 "http://$client_ip/" >/dev/null; then
            print_success "Client is accessible at http://$client_ip"
        else
            print_warning "Client health check failed. This is normal if application is not deployed yet."
        fi
    fi
    
    # Restore original directory
    cd "$current_dir"
}

# Function to show next steps
show_next_steps() {
    print_status "Next Steps:"
    print_status "==========="
    echo ""
    echo "1. Configure GitHub Secrets (shown above)"
    echo "2. Push your code to trigger CI/CD pipeline"
    echo "3. Monitor the GitHub Actions workflow"
    echo "4. Access your applications at the provided URLs"
    echo ""
    print_status "Useful commands:"
    echo "./connect.sh       # Interactive connection to instances"
    echo "./connect.sh server # SSH to server"
    echo "./connect.sh --ssm server # SSM to server"
    echo "./connect.sh --setup-agent # Setup ssh-agent for passphrase"
    echo "terraform destroy  # To destroy infrastructure"
    echo "terraform plan     # To preview changes"
    echo "terraform apply    # To apply changes"
    echo ""
    print_status "SSH Key Notes:"
    if [ -f "$HOME/.ssh/tms-key" ]; then
        if ssh-keygen -y -f "$HOME/.ssh/tms-key" -P "" >/dev/null 2>&1; then
            echo "✅ SSH key has NO passphrase - direct SSH will work"
        else
            echo "🔒 SSH key has passphrase - use ./connect.sh for easier connection"
            echo "   or run: ssh-add ~/.ssh/tms-key (to cache passphrase)"
        fi
    fi
    echo ""
}

# Main function
main() {
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    local terraform_dir="$script_dir/terraform"
    
    print_status "TMS Infrastructure Deployment Script"
    print_status "====================================="
    
    # Check if terraform directory exists
    if [ ! -d "$terraform_dir" ]; then
        print_error "Terraform directory not found: $terraform_dir"
        exit 1
    fi
    
    # Run deployment steps
    check_prerequisites
    generate_ssh_key
    setup_terraform_vars "$terraform_dir"
    deploy_infrastructure "$terraform_dir"
    setup_github_secrets "$terraform_dir"
    validate_deployment "$terraform_dir"
    show_next_steps
    
    print_success "Deployment script completed!"
}

# Run main function
main "$@"
