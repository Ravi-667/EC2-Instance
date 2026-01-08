#!/bin/bash

###########################################
# AWS EC2 Website Deployment Script
# 
# This script automates the deployment of
# your static website to AWS EC2 instance
###########################################

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables (UPDATE THESE)
EC2_IP=""          # Your EC2 public IP address
KEY_PATH=""        # Path to your .pem key file
EC2_USER="ubuntu"  # Default user for Ubuntu AMI
WEBSITE_DIR="website"
REMOTE_DIR="/var/www/html"

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

# Function to check if variables are set
check_config() {
    print_info "Checking configuration..."
    
    if [ -z "$EC2_IP" ]; then
        print_error "EC2_IP is not set. Please update this script with your EC2 instance IP."
        exit 1
    fi
    
    if [ -z "$KEY_PATH" ]; then
        print_error "KEY_PATH is not set. Please update this script with your .pem key file path."
        exit 1
    fi
    
    if [ ! -f "$KEY_PATH" ]; then
        print_error "Key file not found at: $KEY_PATH"
        exit 1
    fi
    
    if [ ! -d "$WEBSITE_DIR" ]; then
        print_error "Website directory not found: $WEBSITE_DIR"
        exit 1
    fi
    
    print_success "Configuration validated"
}

# Function to test SSH connection
test_connection() {
    print_info "Testing SSH connection to EC2 instance..."
    
    ssh -i "$KEY_PATH" -o ConnectTimeout=10 -o BatchMode=yes "$EC2_USER@$EC2_IP" "echo 'Connection successful'" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        print_success "SSH connection successful"
        return 0
    else
        print_error "Cannot connect to EC2 instance. Check your IP, key file, and security group settings."
        return 1
    fi
}

# Function to backup existing website
backup_website() {
    print_info "Creating backup of existing website..."
    
    ssh -i "$KEY_PATH" "$EC2_USER@$EC2_IP" "sudo cp $REMOTE_DIR/index.html $REMOTE_DIR/index.html.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null"
    
    if [ $? -eq 0 ]; then
        print_success "Backup created"
    else
        print_warning "No existing website to backup (this is fine for first deployment)"
    fi
}

# Function to deploy website
deploy_website() {
    print_info "Deploying website files..."
    
    # Copy files to tmp directory first
    scp -i "$KEY_PATH" "$WEBSITE_DIR/index.html" "$EC2_USER@$EC2_IP:/tmp/index.html"
    
    if [ $? -ne 0 ]; then
        print_error "Failed to copy files to EC2 instance"
        exit 1
    fi
    
    # Move files to web root with sudo
    ssh -i "$KEY_PATH" "$EC2_USER@$EC2_IP" "sudo mv /tmp/index.html $REMOTE_DIR/index.html && sudo chmod 644 $REMOTE_DIR/index.html && sudo chown www-data:www-data $REMOTE_DIR/index.html"
    
    if [ $? -eq 0 ]; then
        print_success "Website files deployed"
    else
        print_error "Failed to move files to web directory"
        exit 1
    fi
}

# Function to restart Nginx
restart_nginx() {
    print_info "Restarting Nginx web server..."
    
    ssh -i "$KEY_PATH" "$EC2_USER@$EC2_IP" "sudo systemctl restart nginx"
    
    if [ $? -eq 0 ]; then
        print_success "Nginx restarted successfully"
    else
        print_error "Failed to restart Nginx"
        exit 1
    fi
}

# Function to verify deployment
verify_deployment() {
    print_info "Verifying deployment..."
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$EC2_IP")
    
    if [ "$HTTP_CODE" -eq 200 ]; then
        print_success "Website is accessible (HTTP 200)"
    else
        print_warning "Website returned HTTP $HTTP_CODE"
    fi
}

# Main deployment function
main() {
    echo ""
    echo "======================================"
    echo "  AWS EC2 Website Deployment Script  "
    echo "======================================"
    echo ""
    
    check_config
    echo ""
    
    if ! test_connection; then
        exit 1
    fi
    echo ""
    
    backup_website
    echo ""
    
    deploy_website
    echo ""
    
    restart_nginx
    echo ""
    
    verify_deployment
    echo ""
    
    echo "======================================"
    print_success "Deployment completed successfully!"
    echo "======================================"
    echo ""
    print_info "Your website is now live at: http://$EC2_IP"
    echo ""
}

# Show usage if --help is provided
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "Usage: $0"
    echo ""
    echo "This script deploys your static website to AWS EC2 instance."
    echo ""
    echo "Before running, update the following variables in the script:"
    echo "  - EC2_IP: Your EC2 instance public IP address"
    echo "  - KEY_PATH: Path to your .pem key file"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo ""
    exit 0
fi

# Run main deployment
main
