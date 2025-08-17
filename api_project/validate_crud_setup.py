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
