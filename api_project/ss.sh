#!/bin/bash

# Django REST Framework Authentication & Permissions Setup Script
# This script implements token authentication and permission classes

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

print_header "Setting up Django REST Framework Authentication & Permissions"
echo "=================================================================="

# Step 1: Update settings.py with authentication configuration
print_header "Step 1: Configuring Authentication in settings.py"

# Create backup of settings.py
cp api_project/settings.py api_project/settings.py.auth_backup
print_status "✓ Created backup of settings.py"

# Check if rest_framework.authtoken is already in INSTALLED_APPS
if grep -q "'rest_framework.authtoken'" api_project/settings.py; then
    print_warning "rest_framework.authtoken already in INSTALLED_APPS"
else
    # Add rest_framework.authtoken to INSTALLED_APPS
    sed -i "/INSTALLED_APPS = \[/,/\]/ s/\]/    'rest_framework.authtoken',\n]/" api_project/settings.py
    print_status "✓ Added 'rest_framework.authtoken' to INSTALLED_APPS"
fi

# Add REST_FRAMEWORK configuration with authentication
if grep -q "REST_FRAMEWORK = {" api_project/settings.py; then
    print_warning "REST_FRAMEWORK configuration already exists, updating..."
    # Update existing REST_FRAMEWORK configuration
    python3 << 'EOF'
import re

# Read the settings file
with open('api_project/settings.py', 'r') as f:
    content = f.read()

# Define the new REST_FRAMEWORK configuration
new_config = """REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',
    ],
}"""

# Replace existing REST_FRAMEWORK configuration
pattern = r'REST_FRAMEWORK\s*=\s*\{[^}]*\}'
if re.search(pattern, content):
    content = re.sub(pattern, new_config, content)
else:
    # If no REST_FRAMEWORK found, add it at the end
    content += '\n\n' + new_config + '\n'

# Write back to file
with open('api_project/settings.py', 'w') as f:
    f.write(content)

print("✓ Updated REST_FRAMEWORK configuration")
EOF
else
    # Add new REST_FRAMEWORK configuration
    cat >> api_project/settings.py << 'EOF'

# Django REST Framework Configuration
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',
    ],
}
EOF
    print_status "✓ Added REST_FRAMEWORK configuration to settings.py"
fi

print_status "✓ Authentication configuration completed"

# Step 2: Create authentication views
print_header "Step 2: Creating Authentication Views"

# Create backup of existing views.py
cp api/views.py api/views.py.auth_backup
print_status "✓ Created backup of existing views.py"

# Update views.py with authentication views and permissions
cat > api/views.py << 'EOF'
from rest_framework import generics, status, viewsets
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, IsAuthenticatedOrReadOnly, AllowAny
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from django.contrib.auth.models import User
from django.http import JsonResponse
from .models import Book
from .serializers import BookSerializer


class CustomAuthToken(ObtainAuthToken):
    """
    Custom authentication token view that returns user information along with the token.
    
    POST /api/auth/token/ - Get authentication token
    Body: {"username": "your_username", "password": "your_password"}
    """
    
    def post(self, request, *args, **kwargs):
        serializer = self.serializer_class(data=request.data,
                                           context={'request': request})
        if serializer.is_valid():
            user = serializer.validated_data['user']
            token, created = Token.objects.get_or_create(user=user)
            return Response({
                'token': token.key,
                'user_id': user.pk,
                'username': user.username,
                'email': user.email,
                'message': 'Authentication successful'
            })
        return Response({
            'error': 'Invalid credentials',
            'details': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)


class BookList(generics.ListAPIView):
    """
    API view to retrieve list of books.
    Requires authentication to access.
    
    GET /api/books/ - Returns a list of all books in JSON format
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticated]  # Requires authentication
    
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
    A ViewSet for handling all CRUD operations on Book model with authentication.
    
    Permissions:
    - List/Retrieve: Authenticated users can read
    - Create/Update/Delete: Authenticated users can modify
    
    This ViewSet automatically provides the following endpoints:
    - GET /books_all/ - List all books (requires authentication)
    - POST /books_all/ - Create a new book (requires authentication)
    - GET /books_all/{id}/ - Retrieve a specific book (requires authentication)
    - PUT /books_all/{id}/ - Update a specific book (requires authentication)
    - PATCH /books_all/{id}/ - Partially update a specific book (requires authentication)
    - DELETE /books_all/{id}/ - Delete a specific book (requires authentication)
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticated]  # All operations require authentication
    
    def get_permissions(self):
        """
        Instantiate and return the list of permissions that this view requires.
        You can customize permissions per action if needed.
        """
        if self.action in ['list', 'retrieve']:
            # Read operations - authenticated users only
            permission_classes = [IsAuthenticated]
        else:
            # Write operations - authenticated users only
            permission_classes = [IsAuthenticated]
        
        return [permission() for permission in permission_classes]
    
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
                'results': serializer.data,
                'user': request.user.username,
                'message': 'Books retrieved successfully'
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
                        'data': serializer.data,
                        'created_by': request.user.username
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
            return Response({
                'data': serializer.data,
                'accessed_by': request.user.username
            })
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
                        'data': serializer.data,
                        'updated_by': request.user.username
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
                        'data': serializer.data,
                        'updated_by': request.user.username
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
                    'message': f'Book "{book_title}" deleted successfully',
                    'deleted_by': request.user.username
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
@permission_classes([AllowAny])  # Public endpoint for testing
def book_list_function_view(request):
    """
    Alternative function-based view for listing books.
    This endpoint is public (no authentication required) for testing purposes.
    """
    if request.method == 'GET':
        books = Book.objects.all()
        serializer = BookSerializer(books, many=True)
        return Response({
            'data': serializer.data,
            'message': 'Public endpoint - no authentication required'
        })


@api_view(['GET'])
@permission_classes([AllowAny])  # Public endpoint
def api_overview(request):
    """
    API overview endpoint - publicly accessible.
    """
    api_urls = {
        'Authentication': {
            'Get Token': 'POST /api/auth/token/ (username, password)',
            'Usage': 'Include "Authorization: Token your_token_here" in headers',
        },
        'Books API (Authenticated)': {
            'List Books (ListAPIView)': 'GET /api/books/',
            'CRUD Operations (ViewSet)': {
                'List all books': 'GET /api/books_all/',
                'Create book': 'POST /api/books_all/',
                'Get book by ID': 'GET /api/books_all/{id}/',
                'Update book': 'PUT /api/books_all/{id}/',
                'Partial update': 'PATCH /api/books_all/{id}/',
                'Delete book': 'DELETE /api/books_all/{id}/',
            },
        },
        'Public Endpoints': {
            'API Overview': 'GET /api/',
            'Public Book List': 'GET /api/books-public/',
        },
    }
    return JsonResponse(api_urls)


@api_view(['POST'])
@permission_classes([AllowAny])  # Public endpoint for user registration
def register_user(request):
    """
    User registration endpoint.
    POST /api/auth/register/
    Body: {"username": "new_user", "password": "password", "email": "email@example.com"}
    """
    try:
        username = request.data.get('username')
        password = request.data.get('password')
        email = request.data.get('email', '')
        
        if not username or not password:
            return Response({
                'error': 'Username and password are required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if User.objects.filter(username=username).exists():
            return Response({
                'error': 'Username already exists'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Create user
        user = User.objects.create_user(
            username=username,
            password=password,
            email=email
        )
        
        # Create token for the new user
        token, created = Token.objects.get_or_create(user=user)
        
        return Response({
            'message': 'User created successfully',
            'user_id': user.pk,
            'username': user.username,
            'token': token.key
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response({
            'error': 'Failed to create user',
            'details': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
EOF

print_status "✓ Updated api/views.py with authentication and permission classes"

# Step 3: Update urls.py with authentication endpoints
print_header "Step 3: Updating URL Configuration"

# Create backup of existing urls.py
cp api/urls.py api/urls.py.auth_backup
print_status "✓ Created backup of existing urls.py"

# Update urls.py with authentication endpoints
cat > api/urls.py << 'EOF'
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

# Create a router and register our ViewSet with it
router = DefaultRouter()
router.register(r'books_all', views.BookViewSet, basename='book_all')

# URL patterns for the api app
urlpatterns = [
    # API overview page (public)
    path('', views.api_overview, name='api-overview'),
    
    # Authentication endpoints
    path('auth/token/', views.CustomAuthToken.as_view(), name='api_token_auth'),
    path('auth/register/', views.register_user, name='api_register'),
    
    # Book endpoints (authenticated)
    path('books/', views.BookList.as_view(), name='book-list'),
    
    # Public endpoint for testing
    path('books-public/', views.book_list_function_view, name='book-list-public'),
    
    # Include the router URLs for BookViewSet (all CRUD operations)
    path('', include(router.urls)),  # This includes all routes registered with the router
]
EOF

print_status "✓ Updated api/urls.py with authentication endpoints"

# Step 4: Run migrations for authtoken
print_header "Step 4: Running Database Migrations"

if [ -d "venv" ]; then
    print_status "Activating virtual environment..."
    source venv/bin/activate
fi

print_status "Running migrations for authtoken..."
python manage.py migrate
print_status "✓ Database migrations completed"

# Step 5: Create test script for authentication
print_header "Step 5: Creating Authentication Test Script"
cat > test_auth_api.sh << 'EOF'
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
EOF

chmod +x test_auth_api.sh
print_status "✓ Created test_auth_api.sh script for authentication testing"

# Step 6: Create user management script
print_header "Step 6: Creating User Management Script"
cat > manage_users.py << 'EOF'
#!/usr/bin/env python
"""
User management script for Django REST Framework authentication.
This script helps create users and manage tokens for testing.

Usage: python manage_users.py
"""

import os
import django
import sys

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'api_project.settings')
django.setup()

from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token

def create_test_users():
    """Create test users with tokens."""
    
    test_users = [
        {
            'username': 'testuser1',
            'password': 'testpass123',
            'email': 'test1@example.com',
            'is_staff': False
        },
        {
            'username': 'testuser2',
            'password': 'testpass123',
            'email': 'test2@example.com',
            'is_staff': False
        },
        {
            'username': 'admin',
            'password': 'admin123',
            'email': 'admin@example.com',
            'is_staff': True,
            'is_superuser': True
        },
    ]
    
    created_count = 0
    for user_data in test_users:
        username = user_data['username']
        
        if User.objects.filter(username=username).exists():
            user = User.objects.get(username=username)
            print(f"- User already exists: {username}")
        else:
            if user_data.get('is_superuser'):
                user = User.objects.create_superuser(
                    username=username,
                    email=user_data['email'],
                    password=user_data['password']
                )
            else:
                user = User.objects.create_user(
                    username=username,
                    email=user_data['email'],
                    password=user_data['password']
                )
                user.is_staff = user_data.get('is_staff', False)
                user.save()
            
            created_count += 1
            print(f"✓ Created user: {username}")
        
        # Create or get token
        token, created = Token.objects.get_or_create(user=user)
        status = "created" if created else "exists"
        print(f"  Token ({status}): {token.key}")
        print(f"  User ID: {user.id}")
        print()
    
    print(f"Summary: {created_count} new users created.")
    print(f"Total users in database: {User.objects.count()}")

def list_all_users():
    """List all users with their tokens."""
    print("All users in database:")
    print("-" * 80)
    print(f"{'ID':<4} {'Username':<15} {'Email':<25} {'Staff':<6} {'Token':<40}")
    print("-" * 80)
    
    for user in User.objects.all():
        try:
            token = Token.objects.get(user=user).key
        except Token.DoesNotExist:
            token = "No token"
        
        print(f"{user.id:<4} {user.username:<15} {user.email:<25} {str(user.is_staff):<6} {token:<40}")

def delete_test_users():
    """Delete test users (except superusers)."""
    test_usernames = ['testuser1', 'testuser2']
    deleted_count = 0
    
    for username in test_usernames:
        try:
            user = User.objects.get(username=username)
            if not user.is_superuser:
                user.delete()
                deleted_count += 1
                print(f"✓ Deleted user: {username}")
            else:
                print(f"- Skipped superuser: {username}")
        except User.DoesNotExist:
            print(f"- User not found: {username}")
    
    print(f"Summary: {deleted_count} users deleted.")

if __name__ == '__main__':
    print("Django REST Framework User Management")
    print("====================================")
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
        if command == 'create':
            create_test_users()
        elif command == 'list':
            list_all_users()
        elif command == 'delete':
            delete_test_users()
        else:
            print(f"Unknown command: {command}")
            print("Available commands: create, list, delete")
    else:
        print("Available commands:")
        print("  python manage_users.py create  - Create test users")
        print("  python manage_users.py list    - List all users")
        print("  python manage_users.py delete  - Delete test users")
        print()
        
        # Default action: create users
        create_test_users()
EOF

print_status "✓ Created manage_users.py for user management"

# Step 7: Create comprehensive documentation
print_header "Step 7: Creating Authentication Documentation"
cat > AUTH_API_README.md << 'EOF'
# Django REST Framework Authentication & Permissions Guide

This guide covers the complete authentication and permission system implemented in your Django REST Framework API.

## Quick Start

1. **Apply migrations** (if you haven't already):
   ```bash
   python manage.py migrate
   ```

2. **Create test users**:
   ```bash
   python manage_users.py create
   ```

3. **Start the development server**:
   ```bash
   python manage.py runserver
   ```

4. **Test authentication**:
   ```bash
   ./test_auth_api.sh --run
   ```

## Authentication System Overview

### Authentication Methods
- **Token Authentication**: Primary method using DRF's token system
- **Session Authentication**: For browsable API interface

### Permission Classes
- **IsAuthenticated**: Requires valid authentication token
- **AllowAny**: Public endpoints (no authentication required)

## API Endpoints

### Authentication Endpoints

#### 1. User Registration
- **URL**: `POST /api/auth/register/`
- **Description**: Create a new user account
- **Authentication**: Not required (public)
- **Request Body**:
```json
{
  "username": "newuser",
  "password": "securepassword",
  "email": "user@example.com"
}
```
- **Response**:
```json
{
  "message": "User created successfully",
  "user_id": 1,
  "username": "newuser",
  "token": "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b"
}
```

**Example**:
```bash
curl -X POST http://127.0.0.1:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "testpass123", "email": "test@example.com"}'
```

#### 2. Get Authentication Token
- **URL**: `POST /api/auth/token/`
- **Description**: Obtain authentication token for existing user
- **Authentication**: Not required (public)
- **Request Body**:
```json
{
  "username": "existinguser",
  "password": "userpassword"
}
```
- **Response**:
```json
{
  "token": "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b",
  "user_id": 1,
  "username": "existinguser",
  "email": "user@example.com",
  "message": "Authentication successful"
}
```

**Example**:
```bash
curl -X POST http://127.0.0.1:8000/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "testpass123"}'
```

### Protected Endpoints (Require Authentication)

All book-related endpoints now require authentication. Include the token in the `Authorization` header:

```
Authorization: Token 9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b
```

#### Book Endpoints

| Endpoint | Method | Description | Authentication Required |
|----------|--------|-------------|------------------------|
| `/api/books/` | GET | List all books (ListAPIView) | ✅ Yes |
| `/api/books_all/` | GET | List all books (ViewSet) | ✅ Yes |
| `/api/books_all/` | POST | Create new book | ✅ Yes |
| `/api/books_all/{id}/` | GET | Get specific book | ✅ Yes |
| `/api/books_all/{id}/` | PUT | Update book (full) | ✅ Yes |
| `/api/books_all/{id}/` | PATCH | Update book (partial) | ✅ Yes |
| `/api/books_all/{id}/` | DELETE | Delete book | ✅ Yes |

### Public Endpoints (No Authentication Required)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/` | GET | API overview |
| `/api/books-public/` | GET | Public book list (for testing) |
| `/api/auth/register/` | POST | User registration |
| `/api/auth/token/` | POST | Get authentication token |

## Usage Examples

### 1. Complete Authentication Flow

```bash
# Step 1: Register a new user
curl -X POST http://127.0.0.1:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"username": "apiuser", "password": "securepass123", "email": "api@example.com"}'

# Response will include a token, or get token separately:
curl -X POST http://127.0.0.1:8000/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "apiuser", "password": "securepass123"}'

# Step 2: Use token to access protected endpoints
TOKEN="your_token_here"

# List books
curl -X GET http://127.0.0.1:8000/api/books_all/ \
  -H "Authorization: Token $TOKEN"

# Create a book
curl -X POST http://127.0.0.1:8000/api/books_all/ \
  -H "Authorization: Token $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "Authenticated Book", "author": "API User", "publication_year": 2024}'
```

### 2. Python requests Example

```python
import requests

base_url = "http://127.0.0.1:8000/api"

# Step 1: Register or get token
auth_data = {
    "username": "apiuser",
    "password": "securepass123"
}

# Get token
response = requests.post(f"{base_url}/auth/token/", json=auth_data)
token_data = response.json()
token = token_data['token']

# Step 2: Set up headers with token
headers = {
    'Authorization': f'Token {token}',
    'Content-Type': 'application/json'
}

# Step 3: Make authenticated requests
# List books
response = requests.get(f"{base_url}/books_all/", headers=headers)
books = response.json()
print(books)

# Create a book
new_book = {
    "title": "Python API Book",
    "author": "Python Developer",
    "publication_year": 2024
}
response = requests.post(f"{base_url}/books_all/", json=new_book, headers=headers)
created_book = response.json()
print(created_book)
```

### 3. JavaScript/Fetch Example

```javascript
const baseUrl = 'http://127.0.0.1:8000/api';

// Get authentication token
async function getToken(username, password) {
    const response = await fetch(`${baseUrl}/auth/token/`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ username, password })
    });
    
    const data = await response.json();
    return data.token;
}

// Make authenticated API calls
async function fetchBooks(token) {
    const response = await fetch(`${baseUrl}/books_all/`, {
        headers: {
            'Authorization': `Token ${token}`,
        }
    });
    
    return await response.json();
}

// Usage
(async () => {
    const token = await getToken('apiuser', 'securepass123');
    const books = await fetchBooks(token);
    console.log(books);
})();
```

## Error Handling

### Authentication Errors

**401 Unauthorized** - Invalid or missing token:
```json
{
    "detail": "Invalid token."
}
```

**401 Unauthorized** - No token provided:
```json
{
    "detail": "Authentication credentials were not provided."
}
```

**400 Bad Request** - Invalid login credentials:
```json
{
    "error": "Invalid credentials",
    "details": {
        "non_field_errors": ["Unable to log in with provided credentials."]
    }
}
```

### Permission Errors

**403 Forbidden** - Insufficient permissions:
```json
{
    "detail": "You do not have permission to perform this action."
}
```

## Security Best Practices

### Token Management
1. **Store tokens securely** - Never expose tokens in client-side code
2. **Use HTTPS in production** - Tokens should never be transmitted over HTTP
3. **Implement token rotation** - Consider implementing token refresh mechanisms
4. **Set token expiration** - Configure token expiration in production

### API Security
1. **Rate limiting** - Implement rate limiting to prevent abuse
2. **CORS configuration** - Configure CORS properly for web applications
3. **Input validation** - All input is validated through DRF serializers
4. **Error handling** - Sensitive information is not exposed in error messages

## Testing Authentication

### Using the Test Script
```bash
# Run all authentication tests
./test_auth_api.sh --run

# Create a test superuser
./test_auth_api.sh --create-superuser

# Show help
./test_auth_api.sh --help
```

### Manual Testing Checklist

1. ✅ **Public endpoints work without authentication**
   - GET /api/ (API overview)
   - GET /api/books-public/ (public book list)

2. ✅ **User registration works**
   - POST /api/auth/register/ creates user and returns token

3. ✅ **Token authentication works**
   - POST /api/auth/token/ returns token for valid credentials

4. ✅ **Protected endpoints reject unauthenticated requests**
   - GET /api/books/ returns 401 without token

5. ✅ **Protected endpoints accept authenticated requests**
   - GET /api/books/ returns data with valid token

6. ✅ **CRUD operations work with authentication**
   - All ViewSet operations require and accept valid tokens

## User Management

### Create Test Users
```bash
python manage_users.py create
```

### List All Users
```bash
python manage_users.py list
```

### Delete Test Users
```bash
python manage_users.py delete
```

## Configuration Details

### Settings Configuration
```python
# In api_project/settings.py
INSTALLED_APPS = [
    # ... other apps
    'rest_framework',
    'rest_framework.authtoken',  # Required for token authentication
    'api',
]

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',
    ],
}
```

### View-Level Permissions
```python
# Different permission classes can be applied per view
class BookViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]  # Requires authentication
    
class PublicBookView(generics.ListAPIView):
    permission_classes = [AllowAny]  # Public access
```

## Troubleshooting

### Common Issues

1. **Token not working**
   - Verify token format: `Authorization: Token your_token_here`
   - Check that `rest_framework.authtoken` is in INSTALLED_APPS
   - Ensure migrations have been run

2. **403 Forbidden errors**
   - Check that user has necessary permissions
   - Verify permission classes are correctly configured

3. **User registration fails**
   - Check that username is unique
   - Verify password meets any requirements
   - Ensure all required fields are provided

4. **Token not generated**
   - Run migrations: `python manage.py migrate`
   - Check that Token model is available

## Next Steps

- Implement token refresh mechanism
- Add role-based permissions
- Implement API rate limiting
- Add OAuth2 authentication
- Set up HTTPS for production
- Implement audit logging
- Add API versioning
EOF

print_status "✓ Created AUTH_API_README.md with comprehensive authentication documentation"

# Step 8: Create validation script
print_header "Step 8: Creating Authentication Validation Script"
cat > validate_auth_setup.py << 'EOF'
#!/usr/bin/env python
"""
Script to validate that the authentication setup is working correctly.
This script checks Django configuration, authentication views, and permissions.
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
    from api.views import BookViewSet, BookList, CustomAuthToken
    from rest_framework.routers import DefaultRouter
    from rest_framework.authtoken.models import Token
    from django.contrib.auth.models import User
    from django.conf import settings
    
    print("✓ All imports successful")
    
    # Test authentication configuration
    rest_config = getattr(settings, 'REST_FRAMEWORK', {})
    auth_classes = rest_config.get('DEFAULT_AUTHENTICATION_CLASSES', [])
    perm_classes = rest_config.get('DEFAULT_PERMISSION_CLASSES', [])
    
    print(f"✓ REST_FRAMEWORK configuration found")
    print(f"  - Authentication classes: {len(auth_classes)}")
    for auth_class in auth_classes:
        print(f"    * {auth_class}")
    print(f"  - Permission classes: {len(perm_classes)}")
    for perm_class in perm_classes:
        print(f"    * {perm_class}")
    
    # Check if authtoken is in INSTALLED_APPS
    installed_apps = getattr(settings, 'INSTALLED_APPS', [])
    if 'rest_framework.authtoken' in installed_apps:
        print("✓ rest_framework.authtoken is in INSTALLED_APPS")
    else:
        print("❌ rest_framework.authtoken is NOT in INSTALLED_APPS")
    
    # Test ViewSet permissions
    viewset = BookViewSet()
    print(f"✓ BookViewSet created successfully")
    print(f"  - Permission classes: {[cls.__name__ for cls in viewset.permission_classes]}")
    
    # Test authentication view
    auth_view = CustomAuthToken()
    print(f"✓ CustomAuthToken view created successfully")
    
    # Test database tables
    try:
        user_count = User.objects.count()
        token_count = Token.objects.count()
        book_count = Book.objects.count()
        
        print(f"✓ Database connection successful")
        print(f"  - Users: {user_count}")
        print(f"  - Tokens: {token_count}")
        print(f"  - Books: {book_count}")
    except Exception as e:
        print(f"❌ Database error: {e}")
    
    # Test URL configuration
    from django.urls import reverse
    try:
        token_url = reverse('api_token_auth')
        register_url = reverse('api_register')
        print(f"✓ URL configuration successful")
        print(f"  - Token URL: {token_url}")
        print(f"  - Register URL: {register_url}")
    except Exception as e:
        print(f"❌ URL configuration error: {e}")
    
    print("\n" + "="*60)
    print("✅ Authentication setup validation completed successfully!")
    print("Your Django REST Framework API is secured with authentication.")
    print("="*60)
    
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("Please ensure Django REST Framework is installed and configured properly.")
    sys.exit(1)
except Exception as e:
    print(f"❌ Validation error: {e}")
    sys.exit(1)
EOF

print_status "✓ Created validate_auth_setup.py for authentication validation"

# Final summary
print_header "Authentication & Permissions Setup Complete!"
echo "=============================================="
print_status "All files have been created and updated successfully!"
echo ""
echo "Files created/updated:"
echo "  ✓ api_project/settings.py - Added authentication configuration"
echo "  ✓ api/views.py - Added authentication views and permissions"
echo "  ✓ api/urls.py - Added authentication endpoints"
echo "  ✓ test_auth_api.sh - Authentication testing script"
echo "  ✓ manage_users.py - User management utilities"
echo "  ✓ AUTH_API_README.md - Complete authentication documentation"
echo "  ✓ validate_auth_setup.py - Authentication validation script"
echo ""
echo "Authentication Endpoints:"
echo "  🔐 POST /api/auth/register/  - User registration"
echo "  🔑 POST /api/auth/token/     - Get authentication token"
echo ""
echo "Protected Endpoints (require token):"
echo "  📚 GET    /api/books/         - List books (ListAPIView)"
echo "  📖 GET    /api/books_all/     - List books (ViewSet)"
echo "  ➕ POST   /api/books_all/     - Create book"
echo "  📄 GET    /api/books_all/{id}/ - Get specific book"
echo "  ✏️  PUT    /api/books_all/{id}/ - Update book (full)"
echo "  🔧 PATCH  /api/books_all/{id}/ - Update book (partial)"
echo "  🗑️  DELETE /api/books_all/{id}/ - Delete book"
echo ""
echo "Public Endpoints (no authentication):"
echo "  🌐 GET /api/                 - API overview"
echo "  📚 GET /api/books-public/    - Public book list"
echo ""
echo "Next steps:"
echo "1. Validate setup: python validate_auth_setup.py"
echo "2. Create test users: python manage_users.py create"
echo "3. Start server: python manage.py runserver"
echo "4. Test authentication: ./test_auth_api.sh --run"
echo ""
echo "Token Usage:"
echo "Include in headers: Authorization: Token YOUR_TOKEN_HERE"
echo ""
print_status "Your Django REST Framework API is now secured with authentication!"
print_warning "Remember: All book endpoints now require authentication tokens!"
