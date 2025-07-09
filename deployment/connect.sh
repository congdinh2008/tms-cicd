#!/bin/bash
# SSH Connection Helper Script for TMS Infrastructure

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

# Function to get instance info from terraform
get_instance_info() {
    local terraform_dir="$(dirname "$0")/terraform"
    
    if [ ! -f "$terraform_dir/deployment-outputs.json" ]; then
        print_error "Terraform outputs not found. Please run deployment first."
        print_status "Run: cd deployment && ./deploy.sh"
        exit 1
    fi
    
    # Extract instance information
    SERVER_IP=$(cat "$terraform_dir/deployment-outputs.json" | jq -r '.server_public_ip.value // empty')
    CLIENT_IP=$(cat "$terraform_dir/deployment-outputs.json" | jq -r '.client_public_ip.value // empty')
    SERVER_INSTANCE_ID=$(cat "$terraform_dir/deployment-outputs.json" | jq -r '.server_instance_id.value // empty')
    CLIENT_INSTANCE_ID=$(cat "$terraform_dir/deployment-outputs.json" | jq -r '.client_instance_id.value // empty')
    
    if [ -z "$SERVER_IP" ] || [ -z "$CLIENT_IP" ]; then
        print_error "Could not retrieve instance information from Terraform outputs."
        exit 1
    fi
}

# Function to check SSH key
check_ssh_key() {
    local ssh_key_path="$HOME/.ssh/tms-key"
    
    if [ ! -f "$ssh_key_path" ]; then
        print_error "SSH private key not found at $ssh_key_path"
        print_status "Please ensure SSH key exists or use SSM connection instead."
        exit 1
    fi
    
    # Check if key has passphrase
    if ssh-keygen -y -f "$ssh_key_path" -P "" >/dev/null 2>&1; then
        print_status "SSH key does NOT have a passphrase"
        HAS_PASSPHRASE=false
    else
        print_status "SSH key has a passphrase"
        HAS_PASSPHRASE=true
    fi
}

# Function to setup ssh-agent
setup_ssh_agent() {
    if [ "$HAS_PASSPHRASE" = true ]; then
        print_status "Setting up ssh-agent for passphrase caching..."
        
        # Check if ssh-agent is running
        if [ -z "$SSH_AUTH_SOCK" ]; then
            print_status "Starting ssh-agent..."
            eval $(ssh-agent -s)
        fi
        
        # Add key to agent
        print_status "Adding SSH key to agent (you'll be prompted for passphrase)..."
        ssh-add "$HOME/.ssh/tms-key"
        
        if [ $? -eq 0 ]; then
            print_success "SSH key added to agent successfully!"
            print_status "Passphrase is now cached for this session."
        else
            print_error "Failed to add SSH key to agent."
            return 1
        fi
    fi
}

# Function to connect via SSH
connect_ssh() {
    local target="$1"
    local ip="$2"
    
    print_status "Connecting to $target via SSH..."
    print_status "IP: $ip"
    
    if [ "$HAS_PASSPHRASE" = true ]; then
        print_status "Note: Using ssh-agent cached passphrase"
    fi
    
    ssh -i "$HOME/.ssh/tms-key" ec2-user@"$ip"
}

# Function to connect via SSM
connect_ssm() {
    local target="$1"
    local instance_id="$2"
    
    print_status "Connecting to $target via AWS SSM..."
    print_status "Instance ID: $instance_id"
    
    # Check AWS credentials
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        print_error "AWS credentials not configured. Please run 'aws configure' first."
        return 1
    fi
    
    aws ssm start-session --target "$instance_id"
}

# Function to show connection options
show_connection_menu() {
    echo ""
    print_status "TMS Infrastructure Connection Helper"
    print_status "===================================="
    echo ""
    print_status "Available instances:"
    print_status "1. TMS Server - $SERVER_IP (Instance: $SERVER_INSTANCE_ID)"
    print_status "2. TMS Client - $CLIENT_IP (Instance: $CLIENT_INSTANCE_ID)"
    echo ""
    print_status "Connection methods:"
    print_status "A. SSH (requires SSH key)"
    print_status "B. AWS SSM Session Manager (requires AWS credentials)"
    echo ""
}

# Function to handle connection choice
handle_connection() {
    local choice="$1"
    
    case $choice in
        "1a"|"1A")
            setup_ssh_agent && connect_ssh "TMS Server" "$SERVER_IP"
            ;;
        "1b"|"1B")
            connect_ssm "TMS Server" "$SERVER_INSTANCE_ID"
            ;;
        "2a"|"2A")
            setup_ssh_agent && connect_ssh "TMS Client" "$CLIENT_IP"
            ;;
        "2b"|"2B")
            connect_ssm "TMS Client" "$CLIENT_INSTANCE_ID"
            ;;
        *)
            print_error "Invalid choice: $choice"
            print_status "Valid choices: 1a, 1b, 2a, 2b"
            return 1
            ;;
    esac
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS] [TARGET]"
    echo ""
    echo "OPTIONS:"
    echo "  --ssh          Use SSH connection (default)"
    echo "  --ssm          Use AWS SSM Session Manager"
    echo "  --setup-agent  Setup ssh-agent for passphrase caching"
    echo "  --help         Show this help message"
    echo ""
    echo "TARGET:"
    echo "  server         Connect to TMS Server"
    echo "  client         Connect to TMS Client"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 server              # Connect to server via SSH (interactive if passphrase)"
    echo "  $0 --ssm server        # Connect to server via SSM"
    echo "  $0 --setup-agent       # Setup ssh-agent and cache passphrase"
    echo "  $0                     # Show interactive menu"
    echo ""
    echo "NOTES:"
    echo "  - SSH requires SSH key at ~/.ssh/tms-key"
    echo "  - SSM requires AWS credentials (aws configure)"
    echo "  - If SSH key has passphrase, use --setup-agent first or use SSM"
}

# Main function
main() {
    # Parse command line arguments
    local connection_method="ssh"
    local target=""
    local setup_agent_only=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --ssh)
                connection_method="ssh"
                shift
                ;;
            --ssm)
                connection_method="ssm"
                shift
                ;;
            --setup-agent)
                setup_agent_only=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            server|client)
                target="$1"
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Get instance information
    get_instance_info
    
    # Handle setup-agent only
    if [ "$setup_agent_only" = true ]; then
        check_ssh_key
        setup_ssh_agent
        print_success "ssh-agent setup complete. You can now SSH without entering passphrase."
        exit 0
    fi
    
    # Handle direct target connection
    if [ ! -z "$target" ]; then
        if [ "$connection_method" = "ssh" ]; then
            check_ssh_key
            if [ "$target" = "server" ]; then
                setup_ssh_agent && connect_ssh "TMS Server" "$SERVER_IP"
            elif [ "$target" = "client" ]; then
                setup_ssh_agent && connect_ssh "TMS Client" "$CLIENT_IP"
            fi
        elif [ "$connection_method" = "ssm" ]; then
            if [ "$target" = "server" ]; then
                connect_ssm "TMS Server" "$SERVER_INSTANCE_ID"
            elif [ "$target" = "client" ]; then
                connect_ssm "TMS Client" "$CLIENT_INSTANCE_ID"
            fi
        fi
        return
    fi
    
    # Interactive mode
    check_ssh_key
    show_connection_menu
    
    print_status "Enter your choice (e.g., 1a for Server SSH, 2b for Client SSM):"
    read -p "Choice: " choice
    
    handle_connection "$choice"
}

# Run main function
main "$@"
