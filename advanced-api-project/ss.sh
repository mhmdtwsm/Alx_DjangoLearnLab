#!/bin/bash

# Django REST Framework Generic Views Setup Script
# This script implements custom views and generic views with permissions

set -e  # Exit on any error

echo "🚀 Setting up Django REST Framework Generic Views..."
echo "Current directory: $(pwd)"

# Check if we're in the correct directory
if [[ ! $(pwd) =~ advanced-api-project$ ]]; then
    echo "❌ Error: Please run this script from the advanced-api-project directory"
    echo "Expected: /home/mhmd/study/alx/Alx_DjangoLearnLab/advanced-api-project"
    exit 1
fi

echo "✅ Directory check passed!"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "❌ Error: Virtual environment not found. Please run the initial setup script first."
    exit 1
fi

# Activate virtual environment
echo "🔄 Activating virtual environment..."
source venv/bin/activate

# Verify we're in the virtual environment
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "✅ Virtual environment activated: $VIRTUAL_ENV"
else
    echo "❌ Failed to activate virtual environment"
    exit 1
fi

# Step 1: Create comprehensive views.py with generic views
echo "📝 Creating comprehensive views.py with generic views..."
cat > api/views.py << 'EOF'
from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAuthenticatedOrReadOnly
from django.shortcuts import get_object_or_404
from .models import Book
from .serializers import BookSerializer

# API Home view for testing
@api_view(['GET'])
def api_home(request):
    """
    API Home endpoint that provides information about available endpoints.
    """
    return Response({
        'message': 'Welcome to the Advanced API Project!',
        'status': 'Generic Views implemented',
        'endpoints': {
            'books_list': '/api/books/',
            'book_detail': '/api/books/<id>/',
            'book_create': '/api/books/create/',
            'book_update': '/api/books/<id>/update/',
            'book_delete': '/api/books/<id>/delete/',
        },
        'authentication': 'Token authentication required for write operations',
        'permissions': 'Read-only for anonymous users, full CRUD for authenticated users'
    })


class BookListView(generics.ListAPIView):
    """
    Generic ListView for retrieving all books.
    Allows read-only access to both authenticated and unauthenticated users.
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    
    def get_queryset(self):
        """
        Optionally filter books by title or author using query parameters.
        Example: /api/books/?title=django or /api/books/?author=smith
        """
        queryset = Book.objects.all()
        title = self.request.query_params.get('title')
        author = self.request.query_params.get('author')
        
        if title is not None:
            queryset = queryset.filter(title__icontains=title)
        if author is not None:
            queryset = queryset.filter(author__icontains=author)
            
        return queryset.order_by('title')


class BookDetailView(generics.RetrieveAPIView):
    """
    Generic DetailView for retrieving a single book by ID.
    Allows read-only access to both authenticated and unauthenticated users.
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    lookup_field = 'pk'
    
    def get_object(self):
        """
        Custom method to get object with proper error handling.
        """
        pk = self.kwargs.get('pk')
        return get_object_or_404(Book, pk=pk)


class BookCreateView(generics.CreateAPIView):
    """
    Generic CreateView for adding a new book.
    Requires authentication to create new books.
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticated]
    
    def perform_create(self, serializer):
        """
        Custom create method to add additional functionality.
        You can add custom logic here, such as setting the created_by field.
        """
        # Example: If you had a created_by field, you could set it here
        # serializer.save(created_by=self.request.user)
        serializer.save()
    
    def create(self, request, *args, **kwargs):
        """
        Override create method to provide custom response format.
        """
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            self.perform_create(serializer)
            return Response({
                'message': 'Book created successfully',
                'data': serializer.data
            }, status=status.HTTP_201_CREATED)
        return Response({
            'message': 'Failed to create book',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)


class BookUpdateView(generics.UpdateAPIView):
    """
    Generic UpdateView for modifying an existing book.
    Requires authentication to update books.
    Supports both PUT (full update) and PATCH (partial update).
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = 'pk'
    
    def get_object(self):
        """
        Custom method to get object with proper error handling.
        """
        pk = self.kwargs.get('pk')
        return get_object_or_404(Book, pk=pk)
    
    def perform_update(self, serializer):
        """
        Custom update method to add additional functionality.
        """
        serializer.save()
    
    def update(self, request, *args, **kwargs):
        """
        Override update method to provide custom response format.
        """
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        
        if serializer.is_valid():
            self.perform_update(serializer)
            return Response({
                'message': 'Book updated successfully',
                'data': serializer.data
            })
        return Response({
            'message': 'Failed to update book',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)


class BookDeleteView(generics.DestroyAPIView):
    """
    Generic DeleteView for removing a book.
    Requires authentication to delete books.
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = 'pk'
    
    def get_object(self):
        """
        Custom method to get object with proper error handling.
        """
        pk = self.kwargs.get('pk')
        return get_object_or_404(Book, pk=pk)
    
    def destroy(self, request, *args, **kwargs):
        """
        Override destroy method to provide custom response format.
        """
        instance = self.get_object()
        book_title = instance.title
        self.perform_destroy(instance)
        return Response({
            'message': f'Book "{book_title}" deleted successfully'
        }, status=status.HTTP_200_OK)


# Alternative: Combined CRUD views using mixins (commented out for reference)
"""
from rest_framework import mixins

class BookListCreateView(mixins.ListModelMixin,
                        mixins.CreateModelMixin,
                        generics.GenericAPIView):
    
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    
    def get(self, request, *args, **kwargs):
        return self.list(request, *args, **kwargs)
    
    def post(self, request, *args, **kwargs):
        return self.create(request, *args, **kwargs)


class BookDetailUpdateDeleteView(mixins.RetrieveModelMixin,
                                mixins.UpdateModelMixin,
                                mixins.DestroyModelMixin,
                                generics.GenericAPIView):
    
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    
    def get(self, request, *args, **kwargs):
        return self.retrieve(request, *args, **kwargs)
    
    def put(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)
    
    def patch(self, request, *args, **kwargs):
        return self.partial_update(request, *args, **kwargs)
    
    def delete(self, request, *args, **kwargs):
        return self.destroy(request, *args, **kwargs)
"""
EOF

echo "✅ views.py created with comprehensive generic views"

# Step 2: Create URL patterns
echo "🔗 Creating URL patterns for the views..."
cat > api/urls.py << 'EOF'
from django.urls import path
from . import views

# URL patterns for the API endpoints
urlpatterns = [
    # API Home
    path('', views.api_home, name='api_home'),
    
    # Book CRUD endpoints using separate generic views
    path('books/', views.BookListView.as_view(), name='book_list'),
    path('books/<int:pk>/', views.BookDetailView.as_view(), name='book_detail'),
    path('books/create/', views.BookCreateView.as_view(), name='book_create'),
    path('books/<int:pk>/update/', views.BookUpdateView.as_view(), name='book_update'),
    path('books/<int:pk>/delete/', views.BookDeleteView.as_view(), name='book_delete'),
]

# URL pattern names explanation:
# - book_list: GET /api/books/ - List all books (with optional filtering)
# - book_detail: GET /api/books/<id>/ - Retrieve a specific book
# - book_create: POST /api/books/create/ - Create a new book (auth required)
# - book_update: PUT/PATCH /api/books/<id>/update/ - Update a book (auth required)
# - book_delete: DELETE /api/books/<id>/delete/ - Delete a book (auth required)
EOF

echo "✅ URL patterns created"

# Step 3: Update settings.py to include authentication
echo "⚙️  Updating settings.py for authentication..."
python << 'EOF'
import re

# Read the settings file
settings_file = 'advanced_api_project/settings.py'
with open(settings_file, 'r') as f:
    content = f.read()

# Add REST_FRAMEWORK configuration if not present
rest_framework_config = """
# Django REST Framework Configuration
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticatedOrReadOnly',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_FILTER_BACKENDS': [
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',
    ],
}
"""

# Check if REST_FRAMEWORK is already configured
if 'REST_FRAMEWORK' not in content:
    content += rest_framework_config
    
    # Add authtoken to INSTALLED_APPS if not present
    if "'rest_framework.authtoken'" not in content:
        pattern = r"(INSTALLED_APPS\s*=\s*\[)(.*?)(\])"
        
        def replace_apps(match):
            start = match.group(1)
            apps = match.group(2)
            end = match.group(3)
            
            if "'rest_framework.authtoken'" not in apps:
                apps += "\n    'rest_framework.authtoken',"
            
            return start + apps + "\n" + end
        
        content = re.sub(pattern, replace_apps, content, flags=re.DOTALL)
    
    # Write back to file
    with open(settings_file, 'w') as f:
        f.write(content)
    
    print("✅ Updated settings.py with REST_FRAMEWORK configuration")
else:
    print("ℹ️  REST_FRAMEWORK already configured")
EOF

# Step 4: Update main URLs to include auth endpoints
echo "🔗 Updating main URL configuration..."
cat > advanced_api_project/urls.py << 'EOF'
from django.contrib import admin
from django.urls import path, include
from rest_framework.authtoken.views import obtain_auth_token

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),
    path('api-token-auth/', obtain_auth_token, name='api_token_auth'),
    path('api-auth/', include('rest_framework.urls')),  # Login/logout for browsable API
]
EOF

echo "✅ Main URLs updated with authentication endpoints"

# Step 5: Create migrations for authtoken
echo "🗄️  Creating and applying migrations..."
python manage.py makemigrations
python manage.py migrate

# Step 6: Create test data and management command
echo "📚 Creating test data management command..."
mkdir -p api/management
mkdir -p api/management/commands
touch api/management/__init__.py
touch api/management/commands/__init__.py

cat > api/management/commands/create_test_data.py << 'EOF'
from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token
from api.models import Book

class Command(BaseCommand):
    help = 'Create test data for the API'

    def handle(self, *args, **options):
        # Create test users
        if not User.objects.filter(username='testuser').exists():
            user = User.objects.create_user(
                username='testuser',
                email='test@example.com',
                password='testpass123'
            )
            Token.objects.create(user=user)
            self.stdout.write(
                self.style.SUCCESS(f'Created test user: testuser (token: {user.auth_token.key})')
            )
        
        # Create test books
        test_books = [
            {'title': 'Django for Beginners', 'author': 'William Vincent'},
            {'title': 'Two Scoops of Django', 'author': 'Daniel Roy Greenfeld'},
            {'title': 'Django REST Framework Tutorial', 'author': 'John Doe'},
            {'title': 'Python Crash Course', 'author': 'Eric Matthes'},
            {'title': 'Automate the Boring Stuff', 'author': 'Al Sweigart'},
        ]
        
        for book_data in test_books:
            book, created = Book.objects.get_or_create(**book_data)
            if created:
                self.stdout.write(
                    self.style.SUCCESS(f'Created book: {book.title}')
                )
        
        self.stdout.write(
            self.style.SUCCESS('Test data creation completed!')
        )
EOF

# Step 7: Create comprehensive test script
echo "🧪 Creating test script for API endpoints..."
cat > test_api.py << 'EOF'
#!/usr/bin/env python
"""
API Testing Script for Django REST Framework Generic Views
This script tests all CRUD operations with and without authentication.
"""

import requests
import json
import sys

BASE_URL = 'http://127.0.0.1:8000/api'
AUTH_URL = 'http://127.0.0.1:8000/api-token-auth/'

def get_auth_token():
    """Get authentication token for testuser"""
    data = {
        'username': 'testuser',
        'password': 'testpass123'
    }
    try:
        response = requests.post(AUTH_URL, data=data)
        if response.status_code == 200:
            return response.json()['token']
        else:
            print(f"Failed to get token: {response.status_code}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Error getting token: {e}")
        return None

def test_list_books():
    """Test listing all books (no auth required)"""
    print("\n📚 Testing Book List (GET /api/books/)")
    try:
        response = requests.get(f"{BASE_URL}/books/")
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            books = response.json()
            print(f"Found {len(books)} books")
            for book in books[:3]:  # Show first 3
                print(f"  - {book['title']} by {book['author']}")
        else:
            print(f"Error: {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")

def test_book_detail(book_id=1):
    """Test getting a specific book (no auth required)"""
    print(f"\n📖 Testing Book Detail (GET /api/books/{book_id}/)")
    try:
        response = requests.get(f"{BASE_URL}/books/{book_id}/")
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            book = response.json()
            print(f"Book: {book['title']} by {book['author']}")
        else:
            print(f"Error: {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")

def test_create_book(token):
    """Test creating a new book (auth required)"""
    print("\n➕ Testing Book Creation (POST /api/books/create/)")
    headers = {'Authorization': f'Token {token}'}
    data = {
        'title': 'Test Book from API',
        'author': 'API Tester'
    }
    try:
        response = requests.post(f"{BASE_URL}/books/create/", json=data, headers=headers)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 201:
            result = response.json()
            print(f"Created: {result}")
            return result['data']['id']
        else:
            print(f"Error: {response.text}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return None

def test_update_book(book_id, token):
    """Test updating a book (auth required)"""
    print(f"\n✏️  Testing Book Update (PUT /api/books/{book_id}/update/)")
    headers = {'Authorization': f'Token {token}'}
    data = {
        'title': 'Updated Test Book',
        'author': 'Updated API Tester'
    }
    try:
        response = requests.put(f"{BASE_URL}/books/{book_id}/update/", json=data, headers=headers)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Updated: {result}")
        else:
            print(f"Error: {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")

def test_delete_book(book_id, token):
    """Test deleting a book (auth required)"""
    print(f"\n🗑️  Testing Book Deletion (DELETE /api/books/{book_id}/delete/)")
    headers = {'Authorization': f'Token {token}'}
    try:
        response = requests.delete(f"{BASE_URL}/books/{book_id}/delete/", headers=headers)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Deleted: {result}")
        else:
            print(f"Error: {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")

def test_unauthorized_operations():
    """Test operations without authentication"""
    print("\n🚫 Testing Unauthorized Operations")
    
    # Try to create without auth
    data = {'title': 'Unauthorized Book', 'author': 'No Auth'}
    response = requests.post(f"{BASE_URL}/books/create/", json=data)
    print(f"Create without auth - Status: {response.status_code}")
    
    # Try to update without auth
    data = {'title': 'Updated Title'}
    response = requests.put(f"{BASE_URL}/books/1/update/", json=data)
    print(f"Update without auth - Status: {response.status_code}")
    
    # Try to delete without auth
    response = requests.delete(f"{BASE_URL}/books/1/delete/")
    print(f"Delete without auth - Status: {response.status_code}")

def main():
    print("🧪 Starting API Tests...")
    
    # Test read operations (no auth required)
    test_list_books()
    test_book_detail()
    
    # Test unauthorized operations
    test_unauthorized_operations()
    
    # Get authentication token
    print("\n🔑 Getting authentication token...")
    token = get_auth_token()
    if not token:
        print("❌ Could not get authentication token. Make sure to run:")
        print("   python manage.py create_test_data")
        sys.exit(1)
    
    print(f"✅ Got token: {token[:20]}...")
    
    # Test authenticated operations
    created_book_id = test_create_book(token)
    if created_book_id:
        test_update_book(created_book_id, token)
        test_delete_book(created_book_id, token)
    
    print("\n🎉 API tests completed!")

if __name__ == '__main__':
    main()
EOF

chmod +x test_api.py

# Step 8: Create comprehensive documentation
echo "📝 Creating comprehensive documentation..."
cat > API_DOCUMENTATION.md << 'EOF'
# Django REST Framework Generic Views API Documentation

## Overview
This API provides full CRUD operations for Book management using Django REST Framework's generic views with proper authentication and permissions.

## Authentication
- **Token Authentication**: Required for write operations (CREATE, UPDATE, DELETE)
- **Session Authentication**: Available for web browsing
- **Anonymous Access**: Allowed for read operations (LIST, RETRIEVE)

## Base URL
```
http://127.0.0.1:8000/api/
```

## Authentication Endpoints

### Get Authentication Token
```http
POST /api-token-auth/
```
**Body:**
```json
{
    "username": "your_username",
    "password": "your_password"
}
```
**Response:**
```json
{
    "token": "your_authentication_token"
}
```

## Book Endpoints

### 1. List All Books
```http
GET /api/books/
```
- **Permission**: Public (no authentication required)
- **Description**: Retrieve all books with optional filtering
- **Query Parameters**:
  - `title`: Filter by title (case-insensitive contains)
  - `author`: Filter by author (case-insensitive contains)

**Example:**
```bash
curl -X GET "http://127.0.0.1:8000/api/books/?title=django"
```

**Response:**
```json
[
    {
        "id": 1,
        "title": "Django for Beginners",
        "author": "William Vincent"
    },
    {
        "id": 2,
        "title": "Two Scoops of Django",
        "author": "Daniel Roy Greenfeld"
    }
]
```

### 2. Get Book Details
```http
GET /api/books/{id}/
```
- **Permission**: Public (no authentication required)
- **Description**: Retrieve a specific book by ID

**Example:**
```bash
curl -X GET "http://127.0.0.1:8000/api/books/1/"
```

**Response:**
```json
{
    "id": 1,
    "title": "Django for Beginners",
    "author": "William Vincent"
}
```

### 3. Create New Book
```http
POST /api/books/create/
```
- **Permission**: Authenticated users only
- **Description**: Create a new book

**Headers:**
```
Authorization: Token your_token_here
Content-Type: application/json
```

**Body:**
```json
{
    "title": "New Book Title",
    "author": "Author Name"
}
```

**Example:**
```bash
curl -X POST "http://127.0.0.1:8000/api/books/create/" \
     -H "Authorization: Token your_token_here" \
     -H "Content-Type: application/json" \
     -d '{"title": "New Book", "author": "New Author"}'
```

**Response:**
```json
{
    "message": "Book created successfully",
    "data": {
        "id": 3,
        "title": "New Book Title",
        "author": "Author Name"
    }
}
```

### 4. Update Book
```http
PUT /api/books/{id}/update/
PATCH /api/books/{id}/update/
```
- **Permission**: Authenticated users only
- **Description**: Update an existing book (PUT for full update, PATCH for partial)

**Headers:**
```
Authorization: Token your_token_here
Content-Type: application/json
```

**Body (PUT - all fields required):**
```json
{
    "title": "Updated Book Title",
    "author": "Updated Author Name"
}
```

**Body (PATCH - partial update):**
```json
{
    "title": "Just Update Title"
}
```

**Example:**
```bash
curl -X PATCH "http://127.0.0.1:8000/api/books/1/update/" \
     -H "Authorization: Token your_token_here" \
     -H "Content-Type: application/json" \
     -d '{"title": "Updated Title"}'
```

**Response:**
```json
{
    "message": "Book updated successfully",
    "data": {
        "id": 1,
        "title": "Updated Title",
        "author": "Original Author"
    }
}
```

### 5. Delete Book
```http
DELETE /api/books/{id}/delete/
```
- **Permission**: Authenticated users only
- **Description**: Delete a specific book

**Headers:**
```
Authorization: Token your_token_here
```

**Example:**
```bash
curl -X DELETE "http://127.0.0.1:8000/api/books/1/delete/" \
     -H "Authorization: Token your_token_here"
```

**Response:**
```json
{
    "message": "Book \"Book Title\" deleted successfully"
}
```

## Error Responses

### 401 Unauthorized
```json
{
    "detail": "Authentication credentials were not provided."
}
```

### 403 Forbidden
```json
{
    "detail": "You do not have permission to perform this action."
}
```

### 404 Not Found
```json
{
    "detail": "Not found."
}
```

### 400 Bad Request
```json
{
    "message": "Failed to create book",
    "errors": {
        "title": ["This field is required."]
    }
}
```

## Testing the API

### 1. Setup Test Data
```bash
python manage.py create_test_data
```

### 2. Run Automated Tests
```bash
python test_api.py
```

### 3. Manual Testing with curl

**Get all books:**
```bash
curl -X GET "http://127.0.0.1:8000/api/books/"
```

**Get authentication token:**
```bash
curl -X POST "http://127.0.0.1:8000/api-token-auth/" \
     -d "username=testuser&password=testpass123"
```

**Create a book:**
```bash
curl -X POST "http://127.0.0.1:8000/api/books/create/" \
     -H "Authorization: Token YOUR_TOKEN_HERE" \
     -H "Content-Type: application/json" \
     -d '{"title": "Test Book", "author": "Test Author"}'
```

## Implementation Details

### Generic Views Used
- **BookListView**: `generics.ListAPIView` for listing books
- **BookDetailView**: `generics.RetrieveAPIView` for book details
- **BookCreateView**: `generics.CreateAPIView` for creating books
- **BookUpdateView**: `generics.UpdateAPIView` for updating books
- **BookDeleteView**: `generics.DestroyAPIView` for deleting books

### Permissions
- **IsAuthenticatedOrReadOnly**: Allows read access to everyone, write access only to authenticated users
- **IsAuthenticated**: Requires authentication for all operations

### Custom Features
- Custom response formats with success/error messages
- Query parameter filtering for book list
- Proper error handling with meaningful messages
- Token authentication support
- Browsable API interface available at endpoints
EOF

# Step 9: Update README.md
echo "📄 Updating README.md..."
cat >> README.md << 'EOF'

## Generic Views Implementation

This project now includes comprehensive CRUD operations using Django REST Framework's generic views.

### New Features Added:
- ✅ Generic views for all CRUD operations
- ✅ Token authentication system
- ✅ Proper permission controls
- ✅ Custom response formats
- ✅ Query parameter filtering
- ✅ Comprehensive error handling
- ✅ Test data management command
- ✅ Automated API testing script

### API Endpoints:
- `GET /api/books/` - List all books (public)
- `GET /api/books/<id>/` - Get book details (public)
- `POST /api/books/create/` - Create new book (auth required)
- `PUT/PATCH /api/books/<id>/update/` - Update book (auth required)
- `DELETE /api/books/<id>/delete/` - Delete book (auth required)

### Authentication:
- `POST /api-token-auth/` - Get authentication token
- `GET /api-auth/` - Browsable API login/logout

### Quick Start:
1. Activate virtual environment: `source venv/bin/activate`
2. Create test data: `python manage.py create_test_data`
3. Start server: `python manage.py runserver`
4. Test API: `python test_api.py`

### Documentation:
See `API_DOCUMENTATION.md` for complete API documentation with examples.
EOF

echo ""
echo "🎉 Django REST Framework Generic Views setup complete!"
echo ""
echo "📋 Summary of what was implemented:"
echo "   ✅ Generic views for all CRUD operations"
echo "   ✅ Token authentication with proper permissions"
echo "   ✅ Custom response formats and error handling"
echo "   ✅ URL patterns for all CRUD endpoints"
echo "   ✅ Test data management command"
echo "   ✅ Automated API testing script"
echo "   ✅ Comprehensive API documentation"
echo "   ✅ Query parameter filtering for book list"
echo ""
echo "🚀 Next steps:"
echo "   1. Create test data: python manage.py create_test_data"
echo "   2. Start the development server: python manage.py runserver"
echo "   3. Test the API: python test_api.py"
echo "   4. Visit http://127.0.0.1:8000/api/ to see available endpoints"
echo "   5. Check API_DOCUMENTATION.md for detailed usage examples"
echo ""
echo "🔐 Test credentials:"
echo "   Username: testuser"
echo "   Password: testpass123"
echo ""
echo "📚 API Endpoints:"
echo "   GET    /api/books/              - List all books (public)"
echo "   GET    /api/books/<id>/         - Get book details (public)"
echo "   POST   /api/books/create/       - Create book (auth required)"
echo "   PUT    /api/books/<id>/update/  - Update book (auth required)"
echo "   DELETE /api/books/<id>/delete/  - Delete book (auth required)"
echo ""
echo "Happy coding! 🐍✨"
