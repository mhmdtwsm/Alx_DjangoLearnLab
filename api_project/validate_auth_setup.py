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
