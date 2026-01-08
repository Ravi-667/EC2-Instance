#!/bin/bash

###########################################
# SSH Connection Helper Script
# 
# This script helps you connect to your
# AWS EC2 instance via SSH
###########################################

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration (UPDATE THESE)
EC2_IP=""          # Your EC2 public IP address
KEY_PATH=""        # Path to your .pem key file
EC2_USER="ubuntu"  # Default user for Ubuntu AMI

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if SSH is available
    if ! command -v ssh &> /dev/null; then
        print_error "SSH client not found. Please install OpenSSH."
        exit 1
    fi
    
    # Check if config is set
    if [ -z "$EC2_IP" ]; then
        print_error "EC2_IP is not set. Please update this script."
        exit 1
    fi
    
    if [ -z "$KEY_PATH" ]; then
        print_error "KEY_PATH is not set. Please update this script."
        exit 1
    fi
    
    # Check if key file exists
    if [ ! -f "$KEY_PATH" ]; then
        print_error "Key file not found: $KEY_PATH"
        exit 1
    fi
    
    # Check key file permissions
    KEY_PERMS=$(stat -c %a "$KEY_PATH" 2>/dev/null || stat -f %A "$KEY_PATH" 2>/dev/null)
    if [ "$KEY_PERMS" != "400" ] && [ "$KEY_PERMS" != "600" ]; then
        print_warning "Key file has incorrect permissions: $KEY_PERMS"
        print_info "Setting permissions to 400..."
        chmod 400 "$KEY_PATH"
        print_success "Permissions updated"
    fi
    
    print_success "Prerequisites check passed"
}

# Function to connect via SSH
connect_ssh() {
    echo ""
    print_info "Connecting to EC2 instance..."
    print_info "Instance: $EC2_USER@$EC2_IP"
    print_info "Key: $KEY_PATH"
    echo ""
    echo "======================================"
    
    ssh -i "$KEY_PATH" "$EC2_USER@$EC2_IP"
    
    EXIT_CODE=$?
    
    echo ""
    echo "======================================"
    
    if [ $EXIT_CODE -eq 0 ]; then
        print_success "SSH session ended successfully"
    else
        print_error "SSH connection failed (exit code: $EXIT_CODE)"
        echo ""
        print_info "Troubleshooting tips:"
        echo "  1. Check if EC2 instance is running"
        echo "  2. Verify security group allows SSH (port 22)"
        echo "  3. Confirm public IP address is correct"
        echo "  4. Ensure key file is correct"
        echo "  5. Check your internet connection"
    fi
}

# Show usage
show_usage() {
    echo "AWS EC2 SSH Connection Helper"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -i, --info     Show connection information"
    echo "  -t, --test     Test SSH connection only"
    echo ""
    echo "Before running, update the following variables:"
    echo "  - EC2_IP: Your EC2 instance public IP"
    echo "  - KEY_PATH: Path to your .pem key file"
}

# Test connection
test_connection() {
    print_info "Testing SSH connection..."
    
    ssh -i "$KEY_PATH" -o ConnectTimeout=10 -o BatchMode=yes "$EC2_USER@$EC2_IP" "echo 'Connection test successful'" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        print_success "Connection test passed"
        exit 0
    else
        print_error "Connection test failed"
        exit 1
    fi
}

# Show connection info
show_info() {
    echo ""
    echo "======================================"
    echo "  SSH Connection Information"
    echo "======================================"
    echo ""
    echo "User:        $EC2_USER"
    echo "Host:        $EC2_IP"
    echo "Key File:    $KEY_PATH"
    echo ""
    echo "Full command:"
    echo "  ssh -i $KEY_PATH $EC2_USER@$EC2_IP"
    echo ""
    echo "======================================"
}

# Parse command line arguments
case "$1" in
    -h|--help)
        show_usage
        exit 0
        ;;
    -i|--info)
        check_prerequisites
        show_info
        exit 0
        ;;
    -t|--test)
        check_prerequisites
        test_connection
        exit 0
        ;;
    "")
        check_prerequisites
        connect_ssh
        ;;
    *)
        print_error "Unknown option: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac
