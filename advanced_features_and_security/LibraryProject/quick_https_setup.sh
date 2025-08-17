#!/bin/bash

# Quick HTTPS Setup Script
# This script performs basic setup tasks for HTTPS deployment

set -e

print_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

print_info "Starting HTTPS setup..."

# Check if running as root for system operations
if [[ $EUID -eq 0 ]]; then
    print_warning "Running as root. Be careful with system modifications."
else
    print_info "Running as regular user. Some operations may require sudo."
fi

# Install required packages for SSL/HTTPS
if command -v apt-get &> /dev/null; then
    print_info "Installing required packages (Ubuntu/Debian)..."
    sudo apt-get update
    sudo apt-get install -y openssl nginx certbot python3-certbot-nginx
elif command -v yum &> /dev/null; then
    print_info "Installing required packages (RHEL/CentOS)..."
    sudo yum install -y openssl nginx certbot python3-certbot-nginx
elif command -v brew &> /dev/null; then
    print_info "Installing required packages (macOS)..."
    brew install openssl nginx certbot
else
    print_warning "Package manager not detected. Please install openssl, nginx, and certbot manually."
fi

# Generate development SSL certificates
print_info "Generating development SSL certificates..."
if [ -f "generate_ssl_certificates.sh" ]; then
    ./generate_ssl_certificates.sh
else
    print_warning "SSL certificate generation script not found."
fi

# Check Django settings
print_info "Checking Django settings..."
if grep -q "SECURE_SSL_REDIRECT" LibraryProject/settings.py; then
    print_success "HTTPS settings found in Django configuration"
else
    print_warning "HTTPS settings not found. Please run the main configuration script."
fi

# Collect static files
print_info "Collecting static files..."
python manage.py collectstatic --noinput || print_warning "Static files collection failed. Run manually if needed."

print_success "Quick HTTPS setup completed!"
print_info "Next steps:"
echo "  1. Review and customize web server configuration files"
echo "  2. Update domain names and certificate paths"
echo "  3. For production, obtain proper SSL certificates"
echo "  4. Test the configuration before deploying"
