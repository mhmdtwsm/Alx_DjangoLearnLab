#!/bin/bash

# Django REST Framework Filtering, Searching, and Ordering Implementation Script
# Streamlined version for existing Django projects

set -e  # Exit on any error

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}===================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===================================================${NC}"
}

print_step() {
    echo -e "\n${CYAN}➤ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${PURPLE}ℹ $1${NC}"
}

# Check if we're in the correct directory
check_directory() {
    print_step "Checking project directory structure..."
    
    if [[ ! -f "manage.py" ]]; then
        print_error "manage.py not found. Please run this script from the advanced-api-project root directory."
        exit 1
    fi
    
    if [[ ! -d "advanced_api_project" ]]; then
        print_error "advanced_api_project directory not found."
        exit 1
    fi
    
    if [[ ! -d "api" ]]; then
        print_error "api directory not found."
        exit 1
    fi
    
    print_success "Directory structure verified"
}

# Install django-filter
install_django_filter() {
    print_header "STEP 1: INSTALLING DJANGO-FILTER"
    
    print_step "Adding django-filter to requirements.txt..."
    if ! grep -q "django-filter" requirements.txt 2>/dev/null; then
        echo "django-filter>=23.2" >> requirements.txt
        print_success "Added django-filter to requirements.txt"
    else
        print_warning "django-filter already exists in requirements.txt"
    fi
    
    print_step "Installing django-filter..."
    # Check if we're in venv
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        pip install django-filter>=23.2
        print_success "django-filter installed successfully"
    else
        print_warning "Virtual environment not detected. Installing system-wide..."
        pip3 install django-filter>=23.2
        print_success "django-filter installed"
    fi
}

# Update Django settings
update_settings() {
    print_header "STEP 2: UPDATING DJANGO SETTINGS"
    
    print_step "Backing up settings.py..."
    cp advanced_api_project/settings.py advanced_api_project/settings.py.backup
    print_success "Settings backup created"
    
    print_step "Adding django_filters to INSTALLED_APPS..."
    if ! grep -q "django_filters" advanced_api_project/settings.py; then
        # Use Python to properly modify the INSTALLED_APPS
        python3 << 'EOF'
import re

# Read the settings file
with open('advanced_api_project/settings.py', 'r') as f:
    content = f.read()

# Add django_filters to INSTALLED_APPS if not already present
if "'django_filters'" not in content and '"django_filters"' not in content:
    # Find INSTALLED_APPS and add django_filters
    pattern = r'(INSTALLED_APPS\s*=\s*\[)(.*?)(\])'
    
    def replace_apps(match):
        start, apps_content, end = match.groups()
        # Add django_filters before the closing bracket
        if apps_content.strip():
            # Add comma after last app if not present
            apps_content = apps_content.rstrip()
            if not apps_content.endswith(','):
                apps_content += ','
            return f"{start}{apps_content}\n    'django_filters',{end}"
        else:
            return f"{start}\n    'django_filters',{end}"
    
    content = re.sub(pattern, replace_apps, content, flags=re.DOTALL)

# Write the modified content back
with open('advanced_api_project/settings.py', 'w') as f:
    f.write(content)

print("django_filters added to INSTALLED_APPS")
EOF
        print_success "Added django_filters to INSTALLED_APPS"
    else
        print_warning "django_filters already in INSTALLED_APPS"
    fi
    
    print_step "Adding REST_FRAMEWORK configuration..."
    if ! grep -q "REST_FRAMEWORK" advanced_api_project/settings.py; then
        cat >> advanced_api_project/settings.py << 'EOF'

# Django REST Framework Configuration for Filtering, Searching, and Ordering
REST_FRAMEWORK = {
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 10,
}
EOF
        print_success "Added REST_FRAMEWORK configuration"
    else
        print_warning "REST_FRAMEWORK configuration already exists"
    fi
}

# Create filters.py
create_filters() {
    print_header "STEP 3: CREATING CUSTOM FILTERS"
    
    print_step "Creating api/filters.py..."
    cat > api/filters.py << 'EOF'
"""
Custom filters for the Book API.

This module defines filtering capabilities for the Book model,
allowing users to filter books by various attributes with different
lookup types for enhanced API usability.
"""

import django_filters
from .models import Book


class BookFilter(django_filters.FilterSet):
    """
    Comprehensive filter set for the Book model.
    
    Provides multiple filtering options:
    - Title filtering (exact match and case-insensitive contains)
    - Author filtering (exact match and case-insensitive contains)
    - Publication year filtering (exact, range, greater than, less than)
    """
    
    # Title filters
    title = django_filters.CharFilter(
        lookup_expr='icontains',
        help_text="Filter by title containing the specified text (case-insensitive)"
    )
    title_exact = django_filters.CharFilter(
        field_name='title',
        lookup_expr='exact',
        help_text="Filter by exact title match"
    )
    
    # Author filters
    author = django_filters.CharFilter(
        lookup_expr='icontains',
        help_text="Filter by author name containing the specified text (case-insensitive)"
    )
    author_exact = django_filters.CharFilter(
        field_name='author',
        lookup_expr='exact',
        help_text="Filter by exact author name match"
    )
    
    # Publication year filters
    publication_year = django_filters.NumberFilter(
        help_text="Filter by exact publication year"
    )
    publication_year_gte = django_filters.NumberFilter(
        field_name='publication_year',
        lookup_expr='gte',
        help_text="Filter books published in or after the specified year"
    )
    publication_year_lte = django_filters.NumberFilter(
        field_name='publication_year',
        lookup_expr='lte',
        help_text="Filter books published in or before the specified year"
    )
    publication_year_range = django_filters.RangeFilter(
        field_name='publication_year',
        help_text="Filter books published within a year range"
    )
    
    class Meta:
        model = Book
        fields = {
            'title': ['exact', 'icontains'],
            'author': ['exact', 'icontains'], 
            'publication_year': ['exact', 'gte', 'lte', 'range'],
        }
EOF
    
    print_success "Created comprehensive filters in api/filters.py"
}

# Update views.py with filtering, searching, and ordering
update_views() {
    print_header "STEP 4: UPDATING API VIEWS"
    
    print_step "Backing up current views.py..."
    cp api/views.py api/views.py.backup
    print_success "Views backup created"
    
    print_step "Updating views.py with filtering, searching, and ordering..."
    cat > api/views.py << 'EOF'
"""
Enhanced API Views with Filtering, Searching, and Ordering.

This module provides comprehensive API views for the Book model with
advanced query capabilities including filtering, searching, and ordering.
"""

from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter
from django.shortcuts import get_object_or_404

from .models import Book
from .serializers import BookSerializer
from .filters import BookFilter


class BookListView(generics.ListCreateAPIView):
    """
    Enhanced Book List View with filtering, searching, and ordering.
    
    Features:
    - **Filtering**: Filter by title, author, and publication_year with various lookup types
    - **Searching**: Search across title and author fields simultaneously  
    - **Ordering**: Sort results by any Book model field
    - **Pagination**: Paginated results for better performance
    
    ## Filtering Options:
    - `title`: Case-insensitive partial match in title
    - `title_exact`: Exact title match
    - `author`: Case-insensitive partial match in author name
    - `author_exact`: Exact author name match
    - `publication_year`: Exact year match
    - `publication_year_gte`: Books published in or after specified year
    - `publication_year_lte`: Books published in or before specified year
    
    ## Search Functionality:
    - `search`: Search across title and author fields
    
    ## Ordering Options:
    - `ordering`: Order by any field (prefix with '-' for descending)
    - Available fields: title, author, publication_year, id
    - Multiple fields: separate with commas (e.g., 'author,title')
    
    ## Usage Examples:
    - `/api/books/?title=django` - Books with 'django' in title
    - `/api/books/?author=smith&publication_year_gte=2020` - Books by authors containing 'smith' from 2020 onwards
    - `/api/books/?search=python&ordering=-publication_year` - Search 'python', newest first
    - `/api/books/?ordering=author,title` - Order by author, then title
    """
    
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    
    # Configure filter backends
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    
    # Filtering configuration
    filterset_class = BookFilter
    
    # Search configuration
    search_fields = ['title', 'author']
    
    # Ordering configuration
    ordering_fields = ['title', 'author', 'publication_year', 'id']
    ordering = ['title']  # Default ordering
    
    def list(self, request, *args, **kwargs):
        """
        List books with applied filters, search, and ordering.
        """
        queryset = self.filter_queryset(self.get_queryset())
        
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
    
    def create(self, request, *args, **kwargs):
        """
        Create a new book.
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)


class BookDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Retrieve, update, or delete a specific book.
    """
    
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    lookup_field = 'pk'
    
    def retrieve(self, request, *args, **kwargs):
        """
        Retrieve a specific book.
        """
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        return Response(serializer.data)
    
    def update(self, request, *args, **kwargs):
        """
        Update a book.
        """
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        
        if getattr(instance, '_prefetched_objects_cache', None):
            instance._prefetched_objects_cache = {}
        
        return Response(serializer.data)
    
    def destroy(self, request, *args, **kwargs):
        """
        Delete a book.
        """
        instance = self.get_object()
        self.perform_destroy(instance)
        return Response(status=status.HTTP_204_NO_CONTENT)
EOF
    
    print_success "Updated views.py with comprehensive filtering, searching, and ordering"
}

# Create comprehensive test script
create_test_script() {
    print_header "STEP 5: CREATING TEST SCRIPT"
    
    print_step "Creating test script for filtering functionality..."
    cat > test_filtering.py << 'EOF'
#!/usr/bin/env python3
"""
Test script for Django REST Framework filtering, searching, and ordering.
"""

import requests
import json
import sys
from urllib.parse import urlencode

BASE_URL = "http://127.0.0.1:8000"
API_BASE = f"{BASE_URL}/api"

def print_header(text):
    print(f"\n{'='*50}")
    print(f"{text.center(50)}")
    print('='*50)

def print_success(message):
    print(f"✓ {message}")

def print_error(message):
    print(f"✗ {message}")

def make_request(method, endpoint, params=None):
    """Make HTTP request with error handling."""
    url = f"{API_BASE}{endpoint}"
    if params:
        url += f"?{urlencode(params)}"
    
    try:
        response = requests.request(method, url)
        return response
    except requests.exceptions.ConnectionError:
        print_error("Cannot connect to Django server. Make sure it's running on http://127.0.0.1:8000")
        sys.exit(1)
    except Exception as e:
        print_error(f"Request failed: {e}")
        return None

def test_basic_functionality():
    """Test basic API functionality."""
    print_header("Basic API Test")
    
    response = make_request('GET', '/books/')
    if response and response.status_code == 200:
        try:
            data = response.json()
            count = data.get('count', len(data)) if isinstance(data, dict) else len(data)
            print_success(f"API is working. Found {count} books")
            return True
        except json.JSONDecodeError:
            print_error("Invalid JSON response")
            return False
    else:
        print_error("API test failed")
        return False

def test_filtering():
    """Test filtering functionality."""
    print_header("Filtering Tests")
    
    tests = [
        ({'title': 'django'}, 'Title filter'),
        ({'author': 'smith'}, 'Author filter'),
        ({'publication_year': '2023'}, 'Year filter'),
        ({'publication_year_gte': '2020'}, 'Year >= filter'),
    ]
    
    for params, description in tests:
        response = make_request('GET', '/books/', params)
        if response and response.status_code == 200:
            try:
                data = response.json()
                count = data.get('count', len(data.get('results', [])))
                print_success(f"{description}: {count} results")
            except json.JSONDecodeError:
                print_error(f"{description}: Invalid JSON")
        else:
            print_error(f"{description}: Failed")

def test_searching():
    """Test search functionality."""
    print_header("Search Tests")
    
    tests = [
        'python',
        'django',
        'programming'
    ]
    
    for term in tests:
        response = make_request('GET', '/books/', {'search': term})
        if response and response.status_code == 200:
            try:
                data = response.json()
                count = data.get('count', len(data.get('results', [])))
                print_success(f"Search '{term}': {count} results")
            except json.JSONDecodeError:
                print_error(f"Search '{term}': Invalid JSON")
        else:
            print_error(f"Search '{term}': Failed")

def test_ordering():
    """Test ordering functionality."""
    print_header("Ordering Tests")
    
    tests = [
        ('title', 'Title ascending'),
        ('-title', 'Title descending'),
        ('publication_year', 'Year ascending'),
        ('-publication_year', 'Year descending'),
        ('author,title', 'Author then title'),
    ]
    
    for ordering, description in tests:
        response = make_request('GET', '/books/', {'ordering': ordering})
        if response and response.status_code == 200:
            try:
                data = response.json()
                results = data.get('results', [])
                if results:
                    first_title = results[0].get('title', 'N/A')
                    print_success(f"{description}: First book - '{first_title}'")
                else:
                    print_success(f"{description}: No results")
            except json.JSONDecodeError:
                print_error(f"{description}: Invalid JSON")
        else:
            print_error(f"{description}: Failed")

def test_combined():
    """Test combined filtering, searching, and ordering."""
    print_header("Combined Operations")
    
    tests = [
        ({'search': 'python', 'ordering': '-publication_year'}, 'Search + Order'),
        ({'author': 'smith', 'publication_year_gte': '2020'}, 'Author + Year filter'),
        ({'title': 'django', 'ordering': 'title'}, 'Title filter + Order'),
    ]
    
    for params, description in tests:
        response = make_request('GET', '/books/', params)
        if response and response.status_code == 200:
            try:
                data = response.json()
                count = data.get('count', len(data.get('results', [])))
                print_success(f"{description}: {count} results")
            except json.JSONDecodeError:
                print_error(f"{description}: Invalid JSON")
        else:
            print_error(f"{description}: Failed")

def main():
    """Run all tests."""
    print("Django REST Framework Filtering Test Suite")
    
    if not test_basic_functionality():
        print_error("Basic API test failed. Exiting.")
        return
    
    test_filtering()
    test_searching()
    test_ordering()
    test_combined()
    
    print_header("Test Complete")
    print("\nExample API calls:")
    print(f"curl '{API_BASE}/books/?title=django'")
    print(f"curl '{API_BASE}/books/?search=python&ordering=-publication_year'")
    print(f"curl '{API_BASE}/books/?author=smith&publication_year_gte=2020'")

if __name__ == "__main__":
    main()
EOF
    
    chmod +x test_filtering.py
    print_success "Created test script: test_filtering.py"
}

# Create quick documentation
create_quick_docs() {
    print_header "STEP 6: CREATING DOCUMENTATION"
    
    print_step "Creating API usage documentation..."
    cat > FILTERING_GUIDE.md << 'EOF'
# Django REST Framework Filtering, Searching, and Ordering Guide

## Quick Start

Your Book API now supports advanced filtering, searching, and ordering!

## Available Features

### 🔍 Filtering
- `title` - Contains match (case-insensitive)
- `title_exact` - Exact match
- `author` - Contains match (case-insensitive)
- `author_exact` - Exact match
- `publication_year` - Exact year
- `publication_year_gte` - Year >= value
- `publication_year_lte` - Year <= value

### 🔎 Searching
- `search` - Search across title and author fields

### 📊 Ordering
- `ordering` - Sort by field(s)
- Use `-` prefix for descending order
- Multiple fields: `ordering=author,title`

## Usage Examples

```bash
# Filter by title containing 'django'
curl "http://127.0.0.1:8000/api/books/?title=django"

# Search for 'python' and order by newest first
curl "http://127.0.0.1:8000/api/books/?search=python&ordering=-publication_year"

# Filter by author and year range
curl "http://127.0.0.1:8000/api/books/?author=smith&publication_year_gte=2020"

# Multiple filters with ordering
curl "http://127.0.0.1:8000/api/books/?title=django&author=vincent&ordering=title"

# Exact matches
curl "http://127.0.0.1:8000/api/books/?title_exact=Django for Beginners"
```

## Testing

Run the test script to verify everything works:
```bash
python test_filtering.py
```

## Response Format

All responses are paginated and include:
- `count` - Total number of results
- `next` - URL for next page
- `previous` - URL for previous page
- `results` - Array of book objects

Example response:
```json
{
  "count": 25,
  "next": "http://127.0.0.1:8000/api/books/?page=2",
  "previous": null,
  "results": [
    {
      "id": 1,
      "title": "Django for Beginners",
      "author": "William S. Vincent",
      "publication_year": 2023
    }
  ]
}
```
EOF
    
    print_success "Created documentation: FILTERING_GUIDE.md"
}

# Run migrations
run_migrations() {
    print_header "STEP 7: RUNNING MIGRATIONS"
    
    print_step "Running Django migrations..."
    python manage.py makemigrations
    python manage.py migrate
    print_success "Migrations completed"
}

# Main execution function
main() {
    print_header "DJANGO REST FRAMEWORK FILTERING SETUP"
    print_info "Implementing filtering, searching, and ordering for your existing Django project"
    
    # Execute steps
    check_directory
    install_django_filter
    update_settings
    create_filters
    update_views
    create_test_script
    create_quick_docs
    run_migrations
    
    print_header "🎉 IMPLEMENTATION COMPLETE!"
    
    print_success "Successfully implemented:"
    echo "  ✅ Django-filter installed"
    echo "  ✅ Settings updated"
    echo "  ✅ Custom filters created (api/filters.py)"
    echo "  ✅ Views enhanced with filtering/searching/ordering"
    echo "  ✅ Test script created (test_filtering.py)"
    echo "  ✅ Documentation created (FILTERING_GUIDE.md)"
    echo "  ✅ Migrations applied"
    
    print_header "NEXT STEPS"
    print_info "1. Start your Django server:"
    echo "   python manage.py runserver"
    
    print_info "2. Test the implementation:"
    echo "   python test_filtering.py"
    
    print_info "3. Try example API calls:"
    echo "   curl 'http://127.0.0.1:8000/api/books/?title=django'"
    echo "   curl 'http://127.0.0.1:8000/api/books/?search=python&ordering=-publication_year'"
    
    print_info "4. Read the guide:"
    echo "   cat FILTERING_GUIDE.md"
    
    print_success "Your API now supports comprehensive filtering, searching, and ordering! 🚀"
}

# Run the script
main "$@"
