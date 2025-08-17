#!/bin/bash

# API Testing Script
# This script provides various ways to test your new API endpoint

print_test_info() {
    echo -e "\033[1;34m[TEST]\033[0m $1"
}

print_test_info "Django REST Framework API Test Script"
echo "======================================"

# Check if Django server is running
print_test_info "Testing API endpoints..."

# Base URL (adjust if your server runs on different port)
BASE_URL="http://127.0.0.1:8000"

echo ""
echo "1. Testing API Overview endpoint:"
echo "curl ${BASE_URL}/api/"
echo ""

echo "2. Testing Book List endpoint:"
echo "curl ${BASE_URL}/api/books/"
echo ""

echo "3. Testing with formatted JSON output:"
echo "curl -s ${BASE_URL}/api/books/ | python -m json.tool"
echo ""

echo "4. Testing with headers:"
echo "curl -H 'Content-Type: application/json' ${BASE_URL}/api/books/"
echo ""

echo "To run these tests, start your Django development server first:"
echo "python manage.py runserver"
echo ""

print_test_info "You can also test in your browser by visiting:"
echo "- ${BASE_URL}/api/ (API Overview)"
echo "- ${BASE_URL}/api/books/ (Book List)"
