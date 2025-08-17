#!/bin/bash

# Django REST Framework API Endpoint Setup Script
# This script creates all necessary files for the Book API endpoint

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

print_header "Setting up Django REST Framework API Endpoint"
echo "=================================================="

# Step 1: Create serializers.py
print_header "Step 1: Creating serializers.py"
cat > api/serializers.py << 'EOF'
from rest_framework import serializers
from .models import Book


class BookSerializer(serializers.ModelSerializer):
    """
    Serializer for Book model.
    Converts Book model instances to JSON format and vice versa.
    """
    class Meta:
        model = Book
        fields = '__all__'  # Include all fields from the Book model
        
    def validate_title(self, value):
        """
        Custom validation for book title.
        """
        if not value or len(value.strip()) == 0:
            raise serializers.ValidationError("Title cannot be empty.")
        return value
        
    def validate_publication_year(self, value):
        """
        Custom validation for publication year.
        """
        import datetime
        current_year = datetime.datetime.now().year
        if value > current_year:
            raise serializers.ValidationError("Publication year cannot be in the future.")
        return value
EOF

print_status "✓ Created api/serializers.py with BookSerializer"

# Step 2: Update views.py
print_header "Step 2: Updating views.py"
cat > api/views.py << 'EOF'
from rest_framework import generics, status
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
        'List Books': '/api/books/',
        'API Overview': '/api/',
    }
    return JsonResponse(api_urls)
EOF

print_status "✓ Updated api/views.py with BookList view and additional functionality"

# Step 3: Create api/urls.py
print_header "Step 3: Creating api/urls.py"
cat > api/urls.py << 'EOF'
from django.urls import path
from . import views

# URL patterns for the api app
urlpatterns = [
    path('', views.api_overview, name='api-overview'),  # API overview page
    path('books/', views.BookList.as_view(), name='book-list'),  # Main book list endpoint
    path('books-alt/', views.book_list_function_view, name='book-list-alt'),  # Alternative function-based view
]
EOF

print_status "✓ Created api/urls.py with URL patterns"

# Step 4: Update main urls.py to include api app
print_header "Step 4: Updating main project urls.py"

# Check if the api app is already included
if grep -q "path('api/', include('api.urls'))" api_project/urls.py; then
    print_warning "API URLs already included in main urls.py"
else
    # Backup the original urls.py
    cp api_project/urls.py api_project/urls.py.backup
    print_status "✓ Created backup of original urls.py"
    
    # Create updated urls.py
    cat > api_project/urls.py << 'EOF'
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),  # Include API URLs
]
EOF
    print_status "✓ Updated api_project/urls.py to include API routes"
fi

# Step 5: Install Django REST Framework if not already installed
print_header "Step 5: Checking Django REST Framework installation"
if python -c "import rest_framework" 2>/dev/null; then
    print_status "✓ Django REST Framework is already installed"
else
    print_warning "Django REST Framework not found. Adding to requirements.txt..."
    echo "djangorestframework>=3.14.0" >> requirements.txt
    print_status "✓ Added djangorestframework to requirements.txt"
    
    if [ -d "venv" ]; then
        print_status "Installing Django REST Framework in virtual environment..."
        source venv/bin/activate
        pip install djangorestframework
        print_status "✓ Django REST Framework installed"
    else
        print_warning "Virtual environment not found. Please install manually: pip install djangorestframework"
    fi
fi

# Step 6: Update settings.py to include rest_framework
print_header "Step 6: Updating settings.py"
if grep -q "'rest_framework'" api_project/settings.py; then
    print_warning "rest_framework already in INSTALLED_APPS"
else
    # Create backup
    cp api_project/settings.py api_project/settings.py.script_backup
    
    # Add rest_framework to INSTALLED_APPS
    sed -i "/INSTALLED_APPS = \[/,/\]/ s/\]/    'rest_framework',\n]/" api_project/settings.py
    print_status "✓ Added 'rest_framework' to INSTALLED_APPS in settings.py"
fi

# Step 7: Create a test script
print_header "Step 7: Creating test script"
cat > test_api.sh << 'EOF'
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
EOF

chmod +x test_api.sh
print_status "✓ Created test_api.sh script for testing endpoints"

# Step 8: Create sample data script (optional)
print_header "Step 8: Creating sample data script"
cat > create_sample_books.py << 'EOF'
#!/usr/bin/env python
"""
Script to create sample book data for testing the API.
Run this after setting up your database and running migrations.

Usage: python create_sample_books.py
"""

import os
import django
import sys

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'api_project.settings')
django.setup()

from api.models import Book

def create_sample_books():
    """Create sample books for testing the API."""
    
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
    ]
    
    created_count = 0
    for book_data in sample_books:
        book, created = Book.objects.get_or_create(
            title=book_data['title'],
            defaults=book_data
        )
        if created:
            created_count += 1
            print(f"✓ Created book: {book.title}")
        else:
            print(f"- Book already exists: {book.title}")
    
    print(f"\nSummary: {created_count} new books created.")
    print(f"Total books in database: {Book.objects.count()}")

if __name__ == '__main__':
    try:
        create_sample_books()
    except Exception as e:
        print(f"Error creating sample books: {e}")
        sys.exit(1)
EOF

print_status "✓ Created create_sample_books.py for adding test data"

# Step 9: Create README for the API
print_header "Step 9: Creating API documentation"
cat > API_README.md << 'EOF'
# Django REST Framework API - Book Management

This API provides endpoints for managing book data using Django REST Framework.

## Quick Start

1. **Apply migrations** (if you haven't already):
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

2. **Create sample data** (optional):
   ```bash
   python create_sample_books.py
   ```

3. **Start the development server**:
   ```bash
   python manage.py runserver
   ```

4. **Test the API endpoints**:
   ```bash
   ./test_api.sh
   ```

## API Endpoints

### 1. API Overview
- **URL**: `/api/`
- **Method**: GET
- **Description**: Returns an overview of available API endpoints
- **Example**: `curl http://127.0.0.1:8000/api/`

### 2. List All Books
- **URL**: `/api/books/`
- **Method**: GET
- **Description**: Returns a JSON list of all books
- **Example**: `curl http://127.0.0.1:8000/api/books/`

**Sample Response**:
```json
[
  {
    "id": 1,
    "title": "The Django Book",
    "author": "Adrian Holovaty",
    "publication_year": 2009
  },
  {
    "id": 2,
    "title": "Two Scoops of Django", 
    "author": "Daniel Roy Greenfeld",
    "publication_year": 2020
  }
]
```

## Testing Methods

### Using curl
```bash
# Basic request
curl http://127.0.0.1:8000/api/books/

# With pretty JSON formatting
curl -s http://127.0.0.1:8000/api/books/ | python -m json.tool

# With headers
curl -H "Content-Type: application/json" http://127.0.0.1:8000/api/books/
```

### Using Browser
Simply navigate to `http://127.0.0.1:8000/api/books/` in your web browser.

### Using Python requests
```python
import requests
response = requests.get('http://127.0.0.1:8000/api/books/')
print(response.json())
```

## Project Structure

```
api_project/
├── api/
│   ├── __init__.py
│   ├── models.py          # Book model definition
│   ├── serializers.py     # BookSerializer (NEW)
│   ├── views.py          # BookList view (UPDATED)
│   ├── urls.py           # API URL patterns (NEW)
│   └── admin.py
├── api_project/
│   ├── settings.py       # Updated with rest_framework
│   ├── urls.py          # Updated to include api.urls
│   └── ...
├── manage.py
├── test_api.sh          # Testing script
├── create_sample_books.py # Sample data script
└── API_README.md        # This file
```

## Troubleshooting

### Common Issues

1. **ImportError: No module named 'rest_framework'**
   - Solution: Install Django REST Framework
   ```bash
   pip install djangorestframework
   ```

2. **404 Error when accessing /api/books/**
   - Check that `api.urls` is included in main `urls.py`
   - Verify the URL patterns are correct

3. **Empty response or no books**
   - Create sample data using `python create_sample_books.py`
   - Check that your Book model has data in Django admin

4. **Server not starting**
   - Apply migrations: `python manage.py migrate`
   - Check for syntax errors in your code

## Next Steps

- Add POST, PUT, DELETE endpoints for full CRUD operations
- Implement authentication and permissions  
- Add filtering, searching, and pagination
- Write unit tests for your API endpoints
- Add API documentation with tools like Swagger/OpenAPI
EOF

print_status "✓ Created API_README.md with comprehensive documentation"

# Final summary
print_header "Setup Complete!"
echo "=============="
print_status "All files have been created successfully!"
echo ""
echo "Files created/updated:"
echo "  ✓ api/serializers.py - BookSerializer class"
echo "  ✓ api/views.py - BookList view and additional functionality"  
echo "  ✓ api/urls.py - URL patterns for API endpoints"
echo "  ✓ api_project/urls.py - Updated to include API routes"
echo "  ✓ test_api.sh - Script for testing API endpoints"
echo "  ✓ create_sample_books.py - Script to create sample data"
echo "  ✓ API_README.md - Complete API documentation"
echo ""
echo "Next steps:"
echo "1. Run migrations: python manage.py makemigrations && python manage.py migrate"
echo "2. Create sample data: python create_sample_books.py"  
echo "3. Start server: python manage.py runserver"
echo "4. Test API: ./test_api.sh"
echo ""
print_status "Your Django REST Framework API endpoint is ready!"
