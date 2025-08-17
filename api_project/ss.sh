#!/bin/bash

# Django REST Framework Project Setup Script
# This script sets up a new Django project with DRF for the ALX Django Learning Lab

set -e  # Exit on any error

echo "🚀 Starting Django REST Framework Project Setup..."
echo "Current directory: $(pwd)"

# Check if we're in the correct directory
if [[ ! $(pwd) =~ api_project$ ]]; then
    echo "❌ Error: Please run this script from the api_project directory"
    echo "Expected: /home/mhmd/study/alx/Alx_DjangoLearnLab/api_project"
    exit 1
fi

echo "✅ Directory check passed!"

# Step 1: Create and activate virtual environment
echo "🐍 Creating virtual environment..."
if [ ! -d "venv" ]; then
    python -m venv venv
    echo "✅ Virtual environment created"
else
    echo "ℹ️  Virtual environment already exists"
fi

echo "🔄 Activating virtual environment..."
source venv/bin/activate

# Verify we're in the virtual environment
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "✅ Virtual environment activated: $VIRTUAL_ENV"
else
    echo "❌ Failed to activate virtual environment"
    exit 1
fi

# Step 2: Install Django
echo "📦 Installing Django..."
pip install django

# Step 3: Install Django REST Framework
echo "📦 Installing Django REST Framework..."
pip install djangorestframework

# Step 4: Create Django project (only if it doesn't exist)
if [ ! -f "manage.py" ]; then
    echo "🏗️  Creating Django project 'api_project'..."
    django-admin startproject api_project .
else
    echo "ℹ️  Django project already exists, skipping creation..."
fi

# Step 5: Create the api app
echo "🔧 Creating 'api' app..."
if [ ! -d "api" ]; then
    python manage.py startapp api
else
    echo "ℹ️  API app already exists, skipping creation..."
fi

# Step 6: Configure settings.py
echo "⚙️  Configuring settings.py..."
SETTINGS_FILE="api_project/settings.py"

# Backup original settings
cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup"

# Add rest_framework and api to INSTALLED_APPS
python << EOF
import re

# Read the settings file
with open('$SETTINGS_FILE', 'r') as f:
    content = f.read()

# Check if rest_framework is already in INSTALLED_APPS
if "'rest_framework'" not in content:
    # Find INSTALLED_APPS and add rest_framework
    pattern = r"(INSTALLED_APPS\s*=\s*\[)(.*?)(\])"
    
    def replace_apps(match):
        start = match.group(1)
        apps = match.group(2)
        end = match.group(3)
        
        # Add rest_framework if not present
        if "'rest_framework'" not in apps:
            apps += "\n    'rest_framework',"
        
        # Add api if not present
        if "'api'" not in apps:
            apps += "\n    'api',"
        
        return start + apps + "\n" + end
    
    content = re.sub(pattern, replace_apps, content, flags=re.DOTALL)
    
    # Write back to file
    with open('$SETTINGS_FILE', 'w') as f:
        f.write(content)
    
    print("✅ Updated INSTALLED_APPS with 'rest_framework' and 'api'")
else:
    print("ℹ️  INSTALLED_APPS already configured")
EOF

# Step 7: Create the Book model
echo "📚 Creating Book model..."
cat > api/models.py << 'EOF'
from django.db import models

class Book(models.Model):
    title = models.CharField(max_length=200)
    author = models.CharField(max_length=100)
    
    def __str__(self):
        return self.title
    
    class Meta:
        ordering = ['title']
EOF

echo "✅ Book model created in api/models.py"

# Step 8: Create and apply migrations
echo "🗄️  Creating and applying migrations..."
python manage.py makemigrations
python manage.py migrate

# Step 9: Create a superuser (optional, with default credentials for development)
echo "👤 Creating superuser..."
python << EOF
import os
import django
from django.contrib.auth import get_user_model

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'api_project.settings')
django.setup()

User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print("✅ Superuser 'admin' created with password 'admin123'")
else:
    print("ℹ️  Superuser already exists")
EOF

# Step 10: Create basic project structure files
echo "📁 Creating additional project files..."

# Create requirements.txt
cat > requirements.txt << EOF
Django>=4.2.0
djangorestframework>=3.14.0
EOF

# Create .gitignore
cat > .gitignore << EOF
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
env.bak/
venv.bak/

# Django
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal
media/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
EOF

# Create a simple README for the project
cat > README.md << EOF
# API Project - Django REST Framework

This is a Django REST Framework project created for the ALX Django Learning Lab.

## Setup

1. Activate the virtual environment:
   ```
   source venv/bin/activate
   ```

2. Install dependencies (if not using the setup script):
   ```
   pip install -r requirements.txt
   ```

3. Run migrations:
   ```
   python manage.py migrate
   ```

4. Start the development server:
   ```
   python manage.py runserver
   ```

## Models

- **Book**: A simple model with title and author fields

## Admin Access

- Username: admin
- Password: admin123
- Admin URL: http://127.0.0.1:8000/admin/

## API Endpoints

Coming soon in future tasks!
EOF

# Step 11: Register the Book model in admin
echo "🔧 Configuring Django admin..."
cat > api/admin.py << EOF
from django.contrib import admin
from .models import Book

@admin.register(Book)
class BookAdmin(admin.ModelAdmin):
    list_display = ('title', 'author')
    search_fields = ('title', 'author')
    list_filter = ('author',)
EOF

# Step 12: Create a simple view to test the setup
cat > api/views.py << EOF
from django.http import JsonResponse

def api_home(request):
    return JsonResponse({
        'message': 'Welcome to the API Project!',
        'status': 'Setup complete',
        'next_steps': [
            'Visit /admin/ to manage data',
            'Start building API endpoints',
            'Implement serializers and viewsets'
        ]
    })
EOF

# Create basic URL configuration for the api app
cat > api/urls.py << EOF
from django.urls import path
from . import views

urlpatterns = [
    path('', views.api_home, name='api_home'),
]
EOF

# Update main URLs to include api URLs
cat > api_project/urls.py << EOF
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),
]
EOF

echo ""
echo "🎉 Django REST Framework project setup complete!"
echo ""
echo "📋 Summary of what was created:"
echo "   ✅ Virtual environment (venv/)"
echo "   ✅ Django project with DRF installed"
echo "   ✅ 'api' app created and configured"
echo "   ✅ Book model with title and author fields"
echo "   ✅ Database migrations created and applied"
echo "   ✅ Superuser created (admin/admin123)"
echo "   ✅ Admin interface configured"
echo "   ✅ Basic project files (README.md, requirements.txt, .gitignore)"
echo ""
echo "🚀 Next steps:"
echo "   1. Activate virtual environment: source venv/bin/activate"
echo "   2. Start the development server: python manage.py runserver"
echo "   3. Visit http://127.0.0.1:8000/api/ to see the welcome message"
echo "   4. Visit http://127.0.0.1:8000/admin/ to access the admin interface"
echo "   5. Continue with the next tasks to build your API endpoints!"
echo ""
echo "🔐 Admin credentials:"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "Happy coding! 🐍✨"
