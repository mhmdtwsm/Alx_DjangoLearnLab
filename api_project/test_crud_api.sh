#!/bin/bash

# CRUD API Testing Script
# This script provides comprehensive testing for all CRUD operations

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

print_test_info "Django REST Framework CRUD API Test Script"
echo "=============================================="

echo ""
print_test_info "Testing all CRUD operations on BookViewSet..."
echo ""

# Test 1: List all books (GET)
echo "1. LIST ALL BOOKS (GET /api/books_all/)"
echo "   Command: curl -X GET ${BASE_URL}/api/books_all/"
echo "   Expected: JSON list of all books"
echo ""

# Test 2: Create a new book (POST)
echo "2. CREATE A NEW BOOK (POST /api/books_all/)"
echo "   Command: curl -X POST ${BASE_URL}/api/books_all/ \\"
echo "            -H 'Content-Type: application/json' \\"
echo "            -d '{\"title\": \"Test Book\", \"author\": \"Test Author\", \"publication_year\": 2024}'"
echo "   Expected: 201 Created with book data"
echo ""

# Test 3: Get a specific book (GET by ID)
echo "3. GET SPECIFIC BOOK (GET /api/books_all/{id}/)"
echo "   Command: curl -X GET ${BASE_URL}/api/books_all/1/"
echo "   Expected: JSON data for book with ID 1"
echo ""

# Test 4: Update a book (PUT)
echo "4. UPDATE A BOOK (PUT /api/books_all/{id}/)"
echo "   Command: curl -X PUT ${BASE_URL}/api/books_all/1/ \\"
echo "            -H 'Content-Type: application/json' \\"
echo "            -d '{\"title\": \"Updated Book\", \"author\": \"Updated Author\", \"publication_year\": 2024}'"
echo "   Expected: 200 OK with updated book data"
echo ""

# Test 5: Partial update (PATCH)
echo "5. PARTIAL UPDATE (PATCH /api/books_all/{id}/)"
echo "   Command: curl -X PATCH ${BASE_URL}/api/books_all/1/ \\"
echo "            -H 'Content-Type: application/json' \\"
echo "            -d '{\"title\": \"Partially Updated Title\"}'"
echo "   Expected: 200 OK with partially updated book data"
echo ""

# Test 6: Delete a book (DELETE)
echo "6. DELETE A BOOK (DELETE /api/books_all/{id}/)"
echo "   Command: curl -X DELETE ${BASE_URL}/api/books_all/1/"
echo "   Expected: 204 No Content"
echo ""

echo "=============================================="
print_test_info "Additional Testing Options:"
echo ""

# Original ListAPIView endpoint
echo "7. ORIGINAL LIST VIEW (GET /api/books/)"
echo "   Command: curl -X GET ${BASE_URL}/api/books/"
echo "   Expected: JSON list using ListAPIView"
echo ""

# API Overview
echo "8. API OVERVIEW (GET /api/)"
echo "   Command: curl -X GET ${BASE_URL}/api/"
echo "   Expected: JSON overview of all available endpoints"
echo ""

echo "=============================================="
print_test_info "Interactive Testing Functions:"
echo ""

# Function to run actual tests
run_tests() {
    print_test_info "Running actual API tests..."
    
    # Check if server is running
    if ! curl -s "${BASE_URL}/api/" > /dev/null; then
        print_error "Django server is not running on ${BASE_URL}"
        print_warning "Please start the server with: python manage.py runserver"
        return 1
    fi
    
    print_success "Server is running!"
    
    # Test 1: List books
    print_test_info "Testing: List all books"
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X GET "${BASE_URL}/api/books_all/")
    http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    body=$(echo $response | sed -e 's/HTTPSTATUS\:.*//g')
    
    if [ "$http_code" -eq 200 ]; then
        print_success "✓ List books: HTTP $http_code"
        echo "Response: $body" | python -m json.tool 2>/dev/null || echo "$body"
    else
        print_error "✗ List books failed: HTTP $http_code"
        echo "Response: $body"
    fi
    
    echo ""
    
    # Test 2: Create a book
    print_test_info "Testing: Create a new book"
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X POST "${BASE_URL}/api/books_all/" \
        -H "Content-Type: application/json" \
        -d '{"title": "Test Book via Script", "author": "Script Author", "publication_year": 2024}')
    http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    body=$(echo $response | sed -e 's/HTTPSTATUS\:.*//g')
    
    if [ "$http_code" -eq 201 ]; then
        print_success "✓ Create book: HTTP $http_code"
        echo "Response: $body" | python -m json.tool 2>/dev/null || echo "$body"
        
        # Extract book ID for further tests
        book_id=$(echo "$body" | python -c "import sys, json; data=json.load(sys.stdin); print(data.get('data', {}).get('id', 'unknown'))" 2>/dev/null || echo "unknown")
        
        if [ "$book_id" != "unknown" ]; then
            print_test_info "Created book with ID: $book_id"
            
            # Test 3: Get the created book
            print_test_info "Testing: Get book by ID ($book_id)"
            response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X GET "${BASE_URL}/api/books_all/${book_id}/")
            http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
            body=$(echo $response | sed -e 's/HTTPSTATUS\:.*//g')
            
            if [ "$http_code" -eq 200 ]; then
                print_success "✓ Get book by ID: HTTP $http_code"
                echo "Response: $body" | python -m json.tool 2>/dev/null || echo "$body"
            else
                print_error "✗ Get book by ID failed: HTTP $http_code"
            fi
        fi
    else
        print_error "✗ Create book failed: HTTP $http_code"
        echo "Response: $body"
    fi
    
    echo ""
    print_test_info "Basic tests completed. Use the manual commands above for full testing."
}

# Check if user wants to run interactive tests
if [ "$1" = "--run" ]; then
    run_tests
else
    echo "To run interactive tests, use: $0 --run"
    echo ""
    print_warning "Make sure your Django server is running first:"
    echo "python manage.py runserver"
fi
