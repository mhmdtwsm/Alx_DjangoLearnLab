#!/bin/bash

# Django REST Framework CRUD ViewSets Setup Script
# This script implements full CRUD operations using ViewSets and Routers

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if we're in the correct directory
if [ ! -f "manage.py" ]; then
    print_error "manage.py not found. Please run this script from your Django project root directory."
    exit 1
fi

if [ ! -d "api" ]; then
    print_error "api directory not found. Please ensure you have the 'api' app created."
    exit 1
fi

print_header "Setting up Django REST Framework CRUD Operations with ViewSets"
echo "=================================================================="

# Step 1: Update views.py with BookViewSet
print_header "Step 1: Adding BookViewSet to views.py"

# Create backup of existing views.py
cp api/views.py api/views.py.crud_backup
print_status "✓ Created backup of existing views.py"

# Update views.py with ViewSet
cat > api/views.py << 'EOF'
from rest_framework import generics, status, viewsets
from rest_framework.response import Response
from rest_framework.decorators import api_view
from django.http import JsonResponse
from .models import Book
from .serializers import BookSerializer


class BookList(generics.ListAPIView):
    """
    API view to retrieve list of books.
    
    GET /api/books/ - Returns a list of all books in JSON format
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    
    def get(self, request, *args, **kwargs):
        """
        Override get method to add custom response handling.
        """
        try:
            return super().get(request, *args, **kwargs)
        except Exception as e:
            return Response(
                {"error": "Failed to retrieve books", "details": str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class BookViewSet(viewsets.ModelViewSet):
    """
    A ViewSet for handling all CRUD operations on Book model.
    
    This ViewSet automatically provides the following endpoints:
    - GET /books_all/ - List all books
    - POST /books_all/ - Create a new book
    - GET /books_all/{id}/ - Retrieve a specific book
    - PUT /books_all/{id}/ - Update a specific book
    - PATCH /books_all/{id}/ - Partially update a specific book
    - DELETE /books_all/{id}/ - Delete a specific book
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    
    def list(self, request):
        """
        Override list method to add custom response handling.
        GET /books_all/
        """
        try:
            queryset = self.get_queryset()
            serializer = self.get_serializer(queryset, many=True)
            return Response({
                'count': queryset.count(),
                'results': serializer.data
            })
        except Exception as e:
            return Response(
                {"error": "Failed to retrieve books", "details": str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def create(self, request):
        """
        Override create method to add custom response handling.
        POST /books_all/
        """
        try:
            serializer = self.get_serializer(data=request.data)
            if serializer.is_valid():
                self.perform_create(serializer)
                return Response(
                    {
                        'message': 'Book created successfully',
                        'data': serializer.data
                    }, 
                    status=status.HTTP_201_CREATED
                )
            return Response(
                {
                    'error': 'Validation failed',
                    'details': serializer.errors
                }, 
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return Response(
                {"error": "Failed to create book", "details": str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def retrieve(self, request, pk=None):
        """
        Override retrieve method to add custom response handling.
        GET /books_all/{id}/
        """
        try:
            instance = self.get_object()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except Book.DoesNotExist:
            return Response(
                {"error": "Book not found"}, 
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {"error": "Failed to retrieve book", "details": str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def update(self, request, pk=None):
        """
        Override update method to add custom response handling.
        PUT /books_all/{id}/
        """
        try:
            instance = self.get_object()
            serializer = self.get_serializer(instance, data=request.data)
            if serializer.is_valid():
                self.perform_update(serializer)
                return Response(
                    {
                        'message': 'Book updated successfully',
                        'data': serializer.data
                    }
                )
            return Response(
                {
                    'error': 'Validation failed',
                    'details': serializer.errors
                }, 
                status=status.HTTP_400_BAD_REQUEST
            )
        except Book.DoesNotExist:
            return Response(
                {"error": "Book not found"}, 
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {"error": "Failed to update book", "details": str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def partial_update(self, request, pk=None):
        """
        Override partial_update method to add custom response handling.
        PATCH /books_all/{id}/
        """
        try:
            instance = self.get_object()
            serializer = self.get_serializer(instance, data=request.data, partial=True)
            if serializer.is_valid():
                self.perform_update(serializer)
                return Response(
                    {
                        'message': 'Book partially updated successfully',
                        'data': serializer.data
                    }
                )
            return Response(
                {
                    'error': 'Validation failed',
                    'details': serializer.errors
                }, 
                status=status.HTTP_400_BAD_REQUEST
            )
        except Book.DoesNotExist:
            return Response(
                {"error": "Book not found"}, 
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {"error": "Failed to partially update book", "details": str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def destroy(self, request, pk=None):
        """
        Override destroy method to add custom response handling.
        DELETE /books_all/{id}/
        """
        try:
            instance = self.get_object()
            book_title = instance.title  # Store title before deletion
            self.perform_destroy(instance)
            return Response(
                {
                    'message': f'Book "{book_title}" deleted successfully'
                }, 
                status=status.HTTP_204_NO_CONTENT
            )
        except Book.DoesNotExist:
            return Response(
                {"error": "Book not found"}, 
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {"error": "Failed to delete book", "details": str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


@api_view(['GET'])
def book_list_function_view(request):
    """
    Alternative function-based view for listing books.
    This is an example of how you could implement the same functionality
    using a function-based view instead of a class-based view.
    """
    if request.method == 'GET':
        books = Book.objects.all()
        serializer = BookSerializer(books, many=True)
        return Response(serializer.data)


def api_overview(request):
    """
    Simple view to provide API documentation/overview.
    """
    api_urls = {
        'List Books (ListAPIView)': '/api/books/',
        'CRUD Operations (ViewSet)': {
            'List all books': 'GET /api/books_all/',
            'Create book': 'POST /api/books_all/',
            'Get book by ID': 'GET /api/books_all/{id}/',
            'Update book': 'PUT /api/books_all/{id}/',
            'Partial update': 'PATCH /api/books_all/{id}/',
            'Delete book': 'DELETE /api/books_all/{id}/',
        },
        'API Overview': '/api/',
    }
    return JsonResponse(api_urls)
EOF

print_status "✓ Updated api/views.py with BookViewSet for full CRUD operations"

# Step 2: Update urls.py with Router configuration
print_header "Step 2: Updating api/urls.py with Router configuration"

# Create backup of existing urls.py
cp api/urls.py api/urls.py.crud_backup
print_status "✓ Created backup of existing urls.py"

# Update urls.py with Router
cat > api/urls.py << 'EOF'
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

# Create a router and register our ViewSet with it
router = DefaultRouter()
router.register(r'books_all', views.BookViewSet, basename='book_all')

# URL patterns for the api app
urlpatterns = [
    # API overview page
    path('', views.api_overview, name='api-overview'),
    
    # Route for the BookList view (ListAPIView)
    path('books/', views.BookList.as_view(), name='book-list'),
    
    # Alternative function-based view
    path('books-alt/', views.book_list_function_view, name='book-list-alt'),
    
    # Include the router URLs for BookViewSet (all CRUD operations)
    path('', include(router.urls)),  # This includes all routes registered with the router
]
EOF

print_status "✓ Updated api/urls.py with DefaultRouter configuration"

# Step 3: Create comprehensive test script for CRUD operations
print_header "Step 3: Creating CRUD testing script"
cat > test_crud_api.sh << 'EOF'
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
EOF

chmod +x test_crud_api.sh
print_status "✓ Created test_crud_api.sh script for comprehensive CRUD testing"

# Step 4: Create sample data script with more books
print_header "Step 4: Creating enhanced sample data script"
cat > create_sample_books_crud.py << 'EOF'
#!/usr/bin/env python
"""
Enhanced script to create sample book data for testing CRUD operations.
Run this after setting up your database and running migrations.

Usage: python create_sample_books_crud.py
"""

import os
import django
import sys

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'api_project.settings')
django.setup()

from api.models import Book

def create_sample_books():
    """Create sample books for testing CRUD operations."""
    
    sample_books = [
        {
            'title': 'The Django Book',
            'author': 'Adrian Holovaty',
            'publication_year': 2009
        },
        {
            'title': 'Two Scoops of Django',
            'author': 'Daniel Roy Greenfeld',
            'publication_year': 2020
        },
        {
            'title': 'Django for Beginners',
            'author': 'William S. Vincent',
            'publication_year': 2021
        },
        {
            'title': 'Django REST Framework Tutorial',
            'author': 'Test Author',
            'publication_year': 2023
        },
        {
            'title': 'Python Crash Course',
            'author': 'Eric Matthes',
            'publication_year': 2019
        },
        {
            'title': 'Automate the Boring Stuff with Python',
            'author': 'Al Sweigart',
            'publication_year': 2020
        },
        {
            'title': 'Clean Code',
            'author': 'Robert C. Martin',
            'publication_year': 2008
        },
        {
            'title': 'The Pragmatic Programmer',
            'author': 'David Thomas',
            'publication_year': 1999
        },
    ]
    
    created_count = 0
    for book_data in sample_books:
        book, created = Book.objects.get_or_create(
            title=book_data['title'],
            defaults=book_data
        )
        if created:
            created_count += 1
            print(f"✓ Created book: {book.title} (ID: {book.id})")
        else:
            print(f"- Book already exists: {book.title} (ID: {book.id})")
    
    print(f"\nSummary: {created_count} new books created.")
    print(f"Total books in database: {Book.objects.count()}")
    
    # Display all books with their IDs for testing
    print("\nAll books in database:")
    print("-" * 50)
    for book in Book.objects.all():
        print(f"ID: {book.id:2d} | {book.title} by {book.author} ({book.publication_year})")

if __name__ == '__main__':
    try:
        create_sample_books()
    except Exception as e:
        print(f"Error creating sample books: {e}")
        sys.exit(1)
EOF

print_status "✓ Created create_sample_books_crud.py for enhanced test data"

# Step 5: Create comprehensive API documentation
print_header "Step 5: Creating comprehensive CRUD API documentation"
cat > CRUD_API_README.md << 'EOF'
# Django REST Framework CRUD API - Complete Guide

This API provides full CRUD (Create, Read, Update, Delete) operations for managing books using Django REST Framework's ViewSets and Routers.

## Quick Start

1. **Apply migrations** (if you haven't already):
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

2. **Create sample data**:
   ```bash
   python create_sample_books_crud.py
   ```

3. **Start the development server**:
   ```bash
   python manage.py runserver
   ```

4. **Test the CRUD API endpoints**:
   ```bash
   ./test_crud_api.sh --run
   ```

## API Endpoints Overview

### Original ListAPIView Endpoint
- **URL**: `/api/books/`
- **Method**: GET
- **Description**: Returns a simple list of all books (original implementation)

### ViewSet CRUD Endpoints (books_all)

The ViewSet provides full CRUD operations at `/api/books_all/`:

| Operation | HTTP Method | URL | Description |
|-----------|-------------|-----|-------------|
| **List** | GET | `/api/books_all/` | Get all books |
| **Create** | POST | `/api/books_all/` | Create a new book |
| **Retrieve** | GET | `/api/books_all/{id}/` | Get a specific book |
| **Update** | PUT | `/api/books_all/{id}/` | Update a book (full) |
| **Partial Update** | PATCH | `/api/books_all/{id}/` | Update a book (partial) |
| **Delete** | DELETE | `/api/books_all/{id}/` | Delete a book |

## Detailed API Documentation

### 1. List All Books
- **URL**: `GET /api/books_all/`
- **Description**: Retrieve all books in the database
- **Response Format**:
```json
{
  "count": 5,
  "results": [
    {
      "id": 1,
      "title": "The Django Book",
      "author": "Adrian Holovaty",
      "publication_year": 2009
    }
  ]
}
```

**Example**:
```bash
curl -X GET http://127.0.0.1:8000/api/books_all/
```

### 2. Create a New Book
- **URL**: `POST /api/books_all/`
- **Description**: Create a new book
- **Request Body**:
```json
{
  "title": "New Book Title",
  "author": "Author Name",
  "publication_year": 2024
}
```
- **Response Format**:
```json
{
  "message": "Book created successfully",
  "data": {
    "id": 6,
    "title": "New Book Title",
    "author": "Author Name",
    "publication_year": 2024
  }
}
```

**Example**:
```bash
curl -X POST http://127.0.0.1:8000/api/books_all/ \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Book", "author": "Test Author", "publication_year": 2024}'
```

### 3. Retrieve a Specific Book
- **URL**: `GET /api/books_all/{id}/`
- **Description**: Get details of a specific book by ID
- **Response Format**:
```json
{
  "id": 1,
  "title": "The Django Book",
  "author": "Adrian Holovaty",
  "publication_year": 2009
}
```

**Example**:
```bash
curl -X GET http://127.0.0.1:8000/api/books_all/1/
```

### 4. Update a Book (Full Update)
- **URL**: `PUT /api/books_all/{id}/`
- **Description**: Update all fields of a specific book
- **Request Body**: All fields required
```json
{
  "title": "Updated Book Title",
  "author": "Updated Author",
  "publication_year": 2024
}
```
- **Response Format**:
```json
{
  "message": "Book updated successfully",
  "data": {
    "id": 1,
    "title": "Updated Book Title",
    "author": "Updated Author",
    "publication_year": 2024
  }
}
```

**Example**:
```bash
curl -X PUT http://127.0.0.1:8000/api/books_all/1/ \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated Title", "author": "Updated Author", "publication_year": 2024}'
```

### 5. Partial Update a Book
- **URL**: `PATCH /api/books_all/{id}/`
- **Description**: Update specific fields of a book
- **Request Body**: Only fields to update
```json
{
  "title": "New Title Only"
}
```
- **Response Format**:
```json
{
  "message": "Book partially updated successfully",
  "data": {
    "id": 1,
    "title": "New Title Only",
    "author": "Original Author",
    "publication_year": 2009
  }
}
```

**Example**:
```bash
curl -X PATCH http://127.0.0.1:8000/api/books_all/1/ \
  -H "Content-Type: application/json" \
  -d '{"title": "Partially Updated Title"}'
```

### 6. Delete a Book
- **URL**: `DELETE /api/books_all/{id}/`
- **Description**: Delete a specific book
- **Response Format**:
```json
{
  "message": "Book \"Book Title\" deleted successfully"
}
```

**Example**:
```bash
curl -X DELETE http://127.0.0.1:8000/api/books_all/1/
```

## Error Handling

The API provides comprehensive error handling:

### Common Error Responses

**404 Not Found**:
```json
{
  "error": "Book not found"
}
```

**400 Bad Request** (Validation Error):
```json
{
  "error": "Validation failed",
  "details": {
    "title": ["This field is required."],
    "publication_year": ["Publication year cannot be in the future."]
  }
}
```

**500 Internal Server Error**:
```json
{
  "error": "Failed to create book",
  "details": "Specific error message"
}
```

## Testing Methods

### Using curl (Command Line)
```bash
# List all books
curl -X GET http://127.0.0.1:8000/api/books_all/

# Create a book
curl -X POST http://127.0.0.1:8000/api/books_all/ \
  -H "Content-Type: application/json" \
  -d '{"title": "Test", "author": "Author", "publication_year": 2024}'

# Get specific book
curl -X GET http://127.0.0.1:8000/api/books_all/1/

# Update book
curl -X PUT http://127.0.0.1:8000/api/books_all/1/ \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated", "author": "Updated Author", "publication_year": 2024}'

# Partial update
curl -X PATCH http://127.0.0.1:8000/api/books_all/1/ \
  -H "Content-Type: application/json" \
  -d '{"title": "New Title"}'

# Delete book
curl -X DELETE http://127.0.0.1:8000/api/books_all/1/
```

### Using Python requests
```python
import requests
import json

base_url = "http://127.0.0.1:8000/api/books_all/"

# List all books
response = requests.get(base_url)
print(response.json())

# Create a book
new_book = {
    "title": "Python API Book",
    "author": "API Author",
    "publication_year": 2024
}
response = requests.post(base_url, json=new_book)
print(response.json())

# Get specific book (assuming ID 1)
response = requests.get(f"{base_url}1/")
print(response.json())

# Update book
updated_book = {
    "title": "Updated Python Book",
    "author": "Updated Author",
    "publication_year": 2024
}
response = requests.put(f"{base_url}1/", json=updated_book)
print(response.json())

# Partial update
partial_update = {"title": "Partially Updated Title"}
response = requests.patch(f"{base_url}1/", json=partial_update)
print(response.json())

# Delete book
response = requests.delete(f"{base_url}1/")
print(response.status_code)  # Should be 204
```

### Using Browser (for GET requests)
- List all books: `http://127.0.0.1:8000/api/books_all/`
- Get specific book: `http://127.0.0.1:8000/api/books_all/1/`
- API overview: `http://127.0.0.1:8000/api/`

## Project Structure

```
api_project/
├── api/
│   ├── __init__.py
│   ├── models.py              # Book model definition
│   ├── serializers.py         # BookSerializer
│   ├── views.py              # BookList + BookViewSet (UPDATED)
│   ├── urls.py               # Router configuration (UPDATED)
│   └── admin.py
├── api_project/
│   ├── settings.py           # Updated with rest_framework
│   ├── urls.py              # Updated to include api.urls
│   └── ...
├── manage.py
├── test_crud_api.sh         # CRUD testing script
├── create_sample_books_crud.py # Enhanced sample data
└── CRUD_API_README.md       # This documentation
```

## Troubleshooting

### Common Issues

1. **404 Error on ViewSet endpoints**
   - Ensure the router is properly configured in `urls.py`
   - Check that `DefaultRouter` is imported and registered correctly

2. **405 Method Not Allowed**
   - Verify you're using the correct HTTP method for the operation
   - Check that the ViewSet supports the method you're trying to use

3. **400 Bad Request on POST/PUT**
   - Verify your JSON data format matches the serializer requirements
   - Check that all required fields are included
   - Ensure `Content-Type: application/json` header is set

4. **500 Internal Server Error**
   - Check Django server logs for detailed error information
   - Verify database migrations are applied
   - Ensure all required dependencies are installed

### Validation Rules

The API enforces these validation rules:
- **Title**: Cannot be empty or whitespace only
- **Publication Year**: Cannot be in the future
- **All fields**: Required for full updates (PUT)

## Next Steps

- Add authentication and permissions
- Implement filtering, searching, and pagination
- Add more complex validation rules
- Write comprehensive unit tests
- Add API documentation with Swagger/OpenAPI
- Implement rate limiting
- Add caching for better performance
EOF

print_status "✓ Created CRUD_API_README.md with comprehensive documentation"

# Step 6: Create a quick validation script
print_header "Step 6: Creating validation script"
cat > validate_crud_setup.py << 'EOF'
#!/usr/bin/env python
"""
Script to validate that the CRUD setup is working correctly.
This script checks the Django configuration and ViewSet setup.
"""

import os
import django
import sys

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'api_project.settings')

try:
    django.setup()
    
    # Test imports
    from api.models import Book
    from api.serializers import BookSerializer
    from api.views import BookViewSet, BookList
    from rest_framework.routers import DefaultRouter
    
    print("✓ All imports successful")
    
    # Test ViewSet configuration
    viewset = BookViewSet()
    print(f"✓ BookViewSet created successfully")
    print(f"  - Queryset: {viewset.queryset.model.__name__}")
    print(f"  - Serializer: {viewset.serializer_class.__name__}")
    
    # Test Router
    router = DefaultRouter()
    router.register(r'books_all', BookViewSet, basename='book_all')
    urls = router.get_urls()
    print(f"✓ Router configured successfully")
    print(f"  - Generated {len(urls)} URL patterns")
    
    # List some of the generated URLs
    print("  - Generated URL patterns:")
    for url in urls[:6]:  # Show first 6 patterns
        print(f"    * {url.pattern}")
    
    # Test database connection
    book_count = Book.objects.count()
    print(f"✓ Database connection successful")
    print(f"  - Current book count: {book_count}")
    
    print("\n" + "="*50)
    print("✅ CRUD setup validation completed successfully!")
    print("Your Django REST Framework CRUD API is ready to use.")
    print("="*50)
    
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("Please ensure Django REST Framework is installed and configured properly.")
    sys.exit(1)
except Exception as e:
    print(f"❌ Validation error: {e}")
    sys.exit(1)
EOF

print_status "✓ Created validate_crud_setup.py for setup validation"

# Final summary
print_header "CRUD ViewSet Setup Complete!"
echo "============================="
print_status "All files have been created and updated successfully!"
echo ""
echo "Files created/updated:"
echo "  ✓ api/views.py - Added BookViewSet with full CRUD operations"
echo "  ✓ api/urls.py - Updated with DefaultRouter configuration"
echo "  ✓ test_crud_api.sh - Comprehensive CRUD testing script"
echo "  ✓ create_sample_books_crud.py - Enhanced sample data script"
echo "  ✓ CRUD_API_README.md - Complete CRUD API documentation"
echo "  ✓ validate_crud_setup.py - Setup validation script"
echo ""
echo "Available API Endpoints:"
echo "  📖 GET    /api/books_all/     - List all books"
echo "  ➕ POST   /api/books_all/     - Create a new book"
echo "  📄 GET    /api/books_all/{id}/ - Get specific book"
echo "  ✏️  PUT    /api/books_all/{id}/ - Update book (full)"
echo "  🔧 PATCH  /api/books_all/{id}/ - Update book (partial)"
echo "  🗑️  DELETE /api/books_all/{id}/ - Delete book"
echo ""
echo "Next steps:"
echo "1. Validate setup: python validate_crud_setup.py"
echo "2. Create sample data: python create_sample_books_crud.py"
echo "3. Start server: python manage.py runserver"
echo "4. Test CRUD operations: ./test_crud_api.sh --run"
echo ""
print_status "Your Django REST Framework CRUD API with ViewSets is ready!"
print_warning "Remember: The original /api/books/ endpoint still works alongside the new CRUD endpoints!"
