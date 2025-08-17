#!/bin/bash

# Authentication API Testing Script
# This script provides comprehensive testing for authentication and permissions

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_test_info() {
    echo -e "${BLUE}[TEST]${NC} $1"
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

# Base URL (adjust if your server runs on different port)
BASE_URL="http://127.0.0.1:8000"

print_test_info "Django REST Framework Authentication & Permissions Test Script"
echo "=================================================================="

echo ""
print_test_info "Testing Authentication and Permission System..."
echo ""

# Test 1: Public endpoints (no authentication required)
echo "1. PUBLIC ENDPOINTS (No Authentication Required)"
echo "   API Overview: curl -X GET ${BASE_URL}/api/"
echo "   Public Books: curl -X GET ${BASE_URL}/api/books-public/"
echo ""

# Test 2: User registration
echo "2. USER REGISTRATION"
echo "   Command: curl -X POST ${BASE_URL}/api/auth/register/ \\"
echo "            -H 'Content-Type: application/json' \\"
echo "            -d '{\"username\": \"testuser\", \"password\": \"testpass123\", \"email\": \"test@example.com\"}'"
echo "   Expected: 201 Created with user data and token"
echo ""

# Test 3: Token authentication
echo "3. GET AUTHENTICATION TOKEN"
echo "   Command: curl -X POST ${BASE_URL}/api/auth/token/ \\"
echo "            -H 'Content-Type: application/json' \\"
echo "            -d '{\"username\": \"testuser\", \"password\": \"testpass123\"}'"
echo "   Expected: 200 OK with token and user information"
echo ""

# Test 4: Access protected endpoints without token (should fail)
echo "4. ACCESS PROTECTED ENDPOINT WITHOUT TOKEN (Should Fail)"
echo "   Command: curl -X GET ${BASE_URL}/api/books/"
echo "   Expected: 401 Unauthorized"
echo ""

# Test 5: Access protected endpoints with token (should succeed)
echo "5. ACCESS PROTECTED ENDPOINT WITH TOKEN (Should Succeed)"
echo "   Command: curl -X GET ${BASE_URL}/api/books/ \\"
echo "            -H 'Authorization: Token YOUR_TOKEN_HERE'"
echo "   Expected: 200 OK with book data"
echo ""

# Test 6: CRUD operations with authentication
echo "6. CRUD OPERATIONS WITH AUTHENTICATION"
echo "   List Books: curl -X GET ${BASE_URL}/api/books_all/ \\"
echo "               -H 'Authorization: Token YOUR_TOKEN_HERE'"
echo ""
echo "   Create Book: curl -X POST ${BASE_URL}/api/books_all/ \\"
echo "                -H 'Authorization: Token YOUR_TOKEN_HERE' \\"
echo "                -H 'Content-Type: application/json' \\"
echo "                -d '{\"title\": \"Auth Test Book\", \"author\": \"Test Author\", \"publication_year\": 2024}'"
echo ""

echo "=============================================="
print_test_info "Interactive Testing Functions:"
echo ""

# Function to run actual authentication tests
run_auth_tests() {
    print_test_info "Running authentication tests..."
    
    # Check if server is running
    if ! curl -s "${BASE_URL}/api/" > /dev/null; then
        print_error "Django server is not running on ${BASE_URL}"
        print_warning "Please start the server with: python manage.py runserver"
        return 1
    fi
    
    print_success "Server is running!"
    
    # Test 1: Public API overview
    print_test_info "Testing: Public API overview"
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X GET "${BASE_URL}/api/")
    http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    body=$(echo $response | sed -e 's/HTTPSTATUS\:.*//g')
    
    if [ "$http_code" -eq 200 ]; then
        print_success "✓ Public API overview: HTTP $http_code"
    else
        print_error "✗ Public API overview failed: HTTP $http_code"
    fi
    
    echo ""
    
    # Test 2: Try to access protected endpoint without token (should fail)
    print_test_info "Testing: Protected endpoint without token (should fail)"
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X GET "${BASE_URL}/api/books/")
    http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    
    if [ "$http_code" -eq 401 ]; then
        print_success "✓ Protected endpoint correctly rejected: HTTP $http_code"
    else
        print_warning "⚠ Expected 401, got HTTP $http_code"
    fi
    
    echo ""
    
    # Test 3: Register a test user
    print_test_info "Testing: User registration"
    test_username="testuser_$(date +%s)"  # Unique username
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X POST "${BASE_URL}/api/auth/register/" \
        -H "Content-Type: application/json" \
        -d "{\"username\": \"${test_username}\", \"password\": \"testpass123\", \"email\": \"test@example.com\"}")
    http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    body=$(echo $response | sed -e 's/HTTPSTATUS\:.*//g')
    
    if [ "$http_code" -eq 201 ]; then
        print_success "✓ User registration: HTTP $http_code"
        
        # Extract token from response
        token=$(echo "$body" | python -c "import sys, json; data=json.load(sys.stdin); print(data.get('token', 'unknown'))" 2>/dev/null || echo "unknown")
        
        if [ "$token" != "unknown" ]; then
            print_test_info "Got token: ${token:0:20}..."
            
            # Test 4: Access protected endpoint with token
            print_test_info "Testing: Protected endpoint with token"
            response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X GET "${BASE_URL}/api/books/" \
                -H "Authorization: Token $token")
            http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
            
            if [ "$http_code" -eq 200 ]; then
                print_success "✓ Protected endpoint with token: HTTP $http_code"
            else
                print_error "✗ Protected endpoint with token failed: HTTP $http_code"
            fi
        fi
    else
        print_error "✗ User registration failed: HTTP $http_code"
        echo "Response: $body"
    fi
    
    echo ""
    print_test_info "Authentication tests completed."
}

# Function to create a superuser for testing
create_test_superuser() {
    print_test_info "Creating test superuser..."
    
    # Create superuser script
    cat > create_superuser.py << 'PYEOF'
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'api_project.settings')
django.setup()

from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token

username = 'admin'
password = 'admin123'
email = 'admin@example.com'

if not User.objects.filter(username=username).exists():
    user = User.objects.create_superuser(username, email, password)
    token, created = Token.objects.get_or_create(user=user)
    print(f"Superuser created: {username}")
    print(f"Token: {token.key}")
else:
    user = User.objects.get(username=username)
    token, created = Token.objects.get_or_create(user=user)
    print(f"Superuser already exists: {username}")
    print(f"Token: {token.key}")
PYEOF
    
    python create_superuser.py
    rm create_superuser.py
}

# Check command line arguments
case "$1" in
    "--run")
        run_auth_tests
        ;;
    "--create-superuser")
        create_test_superuser
        ;;
    "--help")
        echo "Usage: $0 [--run|--create-superuser|--help]"
        echo "  --run              Run interactive authentication tests"
        echo "  --create-superuser Create a test superuser with token"
        echo "  --help             Show this help message"
        ;;
    *)
        echo "Manual testing commands shown above."
        echo ""
        print_warning "To run interactive tests: $0 --run"
        print_warning "To create test superuser: $0 --create-superuser"
        print_warning "For help: $0 --help"
        echo ""
        print_warning "Make sure your Django server is running first:"
        echo "python manage.py runserver"
        ;;
esac
