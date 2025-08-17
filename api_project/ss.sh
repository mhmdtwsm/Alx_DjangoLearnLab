#!/bin/bash

# Django REST Framework API Setup Script
# This script creates all necessary files for the Book API endpoint

set -e  # Exit on any error

echo "🚀 Setting up Django REST Framework API endpoint for Books..."

# Check if we're in the correct directory
if [ ! -f "manage.py" ]; then
    echo "❌ Error: manage.py not found. Please run this script from the api_project directory."
    exit 1
fi

# Check if api app exists
if [ ! -d "api" ]; then
    echo "❌ Error: api directory not found. Please ensure the api app exists."
    exit 1
fi

echo "✅ Found Django project structure"

# Create serializers.py in the api app
echo "📝 Creating serializers.py..."
cat > api/serializers.py << 'EOF'
from rest_framework import serializers
from .models import Book


class BookSerializer(serializers.ModelSerializer):
    """
    Serializer for the Book model.
    Converts Book model instances to JSON format and vice versa.
    """
    class Meta:
        model = Book
        fields = '__all__'  # Include all fields from the Book model
EOF

echo "✅ Created api/serializers.py"

# Update views.py in the api app
echo "📝 Updating views.py..."
cat > api/views.py << 'EOF'
from rest_framework import generics
from .models import Book
from .serializers import BookSerializer


class BookList(generics.ListAPIView):
    """
    API view to retrieve a list of all books.
    Uses ListAPIView to provide GET method for listing books.
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer
EOF

echo "✅ Updated api/views.py"

# Create urls.py in the api app
echo "📝 Creating api/urls.py..."
cat > api/urls.py << 'EOF'
from django.urls import path
from .views import BookList

urlpatterns = [
    path('books/', BookList.as_view(), name='book-list'),  # Maps to the BookList view
]
EOF

echo "✅ Created api/urls.py"

# Check if main urls.py includes api urls
echo "📝 Checking main urls.py configuration..."
if ! grep -q "path('api/', include('api.urls'))" api_project/urls.py; then
    echo "⚠️  Adding api URLs to main urls.py..."
    
    # Create a backup of the original urls.py
    cp api_project/urls.py api_project/urls.py.backup.$(date +%Y%m%d_%H%M%S)
    
    # Create updated urls.py
    cat > api_project/urls.py << 'EOF'
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),  # Include API URLs
]
EOF
    echo "✅ Updated api_project/urls.py"
else
    echo "✅ API URLs already configured in main urls.py"
fi

# Check if DRF is in requirements.txt
echo "📝 Checking requirements.txt..."
if ! grep -q "djangorestframework" requirements.txt; then
    echo "⚠️  Adding djangorestframework to requirements.txt..."
    echo "djangorestframework" >> requirements.txt
    echo "✅ Added djangorestframework to requirements.txt"
else
    echo "✅ djangorestframework already in requirements.txt"
fi

# Create a test script
echo "📝 Creating test script..."
cat > test_api.sh << 'EOF'
#!/bin/bash

# Test script for the Book API endpoint
echo "🧪 Testing Book API endpoint..."

# Check if server is running
if ! curl -s http://127.0.0.1:8000/api/books/ > /dev/null; then
    echo "❌ Server not responding. Make sure Django development server is running:"
    echo "   python manage.py runserver"
    exit 1
fi

echo "📡 Making API request to http://127.0.0.1:8000/api/books/"
echo "Response:"
curl -s -H "Accept: application/json" http://127.0.0.1:8000/api/books/ | python -m json.tool

echo ""
echo "✅ API test completed!"
EOF

chmod +x test_api.sh
echo "✅ Created test_api.sh"

# Create setup instructions
echo "📝 Creating setup instructions..."
cat > API_SETUP_INSTRUCTIONS.md << 'EOF'
# Django REST Framework API Setup

## Files Created/Modified:

1. **api/serializers.py** - BookSerializer for converting Book models to JSON
2. **api/views.py** - BookList view using ListAPIView
3. **api/urls.py** - URL patterns for the API endpoints
4. **api_project/urls.py** - Updated to include API URLs
5. **requirements.txt** - Added djangorestframework if not present
6. **test_api.sh** - Script to test the API endpoint

## Next Steps:

1. **Install dependencies** (if not already done):
   ```bash
   pip install -r requirements.txt

