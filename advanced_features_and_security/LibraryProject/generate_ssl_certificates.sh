#!/bin/bash

# SSL Certificate Generation Script for Development/Testing
# For production, use certificates from a trusted CA like Let's Encrypt

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

# Create certificates directory
CERT_DIR="ssl_certificates"
mkdir -p "$CERT_DIR"

print_info "Generating SSL certificates for development/testing..."

# Generate private key
openssl genrsa -out "$CERT_DIR/private.key" 2048

# Generate certificate signing request
openssl req -new -key "$CERT_DIR/private.key" -out "$CERT_DIR/certificate.csr" -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Generate self-signed certificate
openssl x509 -req -days 365 -in "$CERT_DIR/certificate.csr" -signkey "$CERT_DIR/private.key" -out "$CERT_DIR/certificate.crt"

# Set appropriate permissions
chmod 600 "$CERT_DIR/private.key"
chmod 644 "$CERT_DIR/certificate.crt"

print_success "SSL certificates generated in $CERT_DIR/"
print_warning "These are self-signed certificates for development only!"
print_warning "For production, use certificates from a trusted CA like Let's Encrypt"

echo ""
echo "Generated files:"
echo "  - $CERT_DIR/private.key (private key)"
echo "  - $CERT_DIR/certificate.crt (certificate)"
echo "  - $CERT_DIR/certificate.csr (certificate signing request)"
