#!/bin/bash

# Django LibraryProject Setup Script
# Following exact task requirements for Alx_DjangoLearnLab/Introduction_to_Django

set -e  # Exit on any error

echo "🚀 Starting Django Development Environment Setup..."
echo "=================================================="
echo ""

# Check if Python is installed
echo "1️⃣  Checking Python installation..."
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
    echo "✅ Python3 found: $(python3 --version)"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
    echo "✅ Python found: $(python --version)"
else
    echo "❌ Error: Python is not installed. Please install Python first."
    exit 1
fi

# Check if pip is available
echo ""
echo "2️⃣  Checking pip installation..."
if command -v pip3 &> /dev/null; then
    PIP_CMD="pip3"
    echo "✅ pip3 found"
elif command -v pip &> /dev/null; then
    PIP_CMD="pip"
    echo "✅ pip found"
else
    echo "❌ Error: pip is not installed. Please install pip first."
    exit 1
fi

# Create the repository structure
echo ""
echo "3️⃣  Creating repository structure..."
REPO_NAME="Alx_DjangoLearnLab"
INTRO_DIR="Introduction_to_Django"

if [ -d "$REPO_NAME" ]; then
    echo "⚠️  Directory $REPO_NAME already exists. Removing it..."
    rm -rf "$REPO_NAME"
fi

mkdir "$REPO_NAME"
cd "$REPO_NAME"
mkdir "$INTRO_DIR"
cd "$INTRO_DIR"
echo "✅ Created repository structure: $REPO_NAME/$INTRO_DIR"

# Create virtual environment
echo ""
echo "4️⃣  Creating Python virtual environment..."
$PYTHON_CMD -m venv django_env
echo "✅ Virtual environment 'django_env' created"

# Activate virtual environment
echo ""
echo "5️⃣  Activating virtual environment..."
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows
    source django_env/Scripts/activate
    ACTIVATE_CMD="django_env\\Scripts\\activate"
else
    # Unix/Linux/MacOS
    source django_env/bin/activate
    ACTIVATE_CMD="source django_env/bin/activate"
fi
echo "✅ Virtual environment activated"

# Install Django - Step 1 from task
echo ""
echo "6️⃣  Step 1: Install Django..."
echo "Running: pip install django"
pip install django
echo "✅ Django installed successfully"
echo "📦 Django version: $(django-admin --version)"

# Create Django Project - Step 2 from task
echo ""
echo "7️⃣  Step 2: Create Your Django Project..."
echo "Running: django-admin startproject LibraryProject"
django-admin startproject LibraryProject
echo "✅ LibraryProject created"

# Step 3: Run the Development Server setup
echo ""
echo "8️⃣  Step 3: Preparing to Run the Development Server..."
echo "Navigating into project directory (cd LibraryProject)"
cd LibraryProject

# Create README.md file inside LibraryProject as specified
echo ""
echo "9️⃣  Creating README.md file inside LibraryProject..."
cat > README.md << 'EOF'
# LibraryProject

This Django project is part of the Alx_DjangoLearnLab repository, specifically created for the Introduction to Django Development Environment Setup task.

## Overview

LibraryProject is a Django web application designed as a foundation for developing Django applications. This project serves as an introduction to Django's workflow, including project creation, configuration, and running the development server.

## Project Setup Steps

This project was created following these exact steps from the task requirements:

### Step 1: Install Django
- Ensured Python is installed on the system
- Installed Django using pip: `pip install django`

### Step 2: Create Your Django Project  
- Created new Django project by running: `django-admin startproject LibraryProject`

### Step 3: Run the Development Server
- Navigated into project directory: `cd LibraryProject`
- Created this README.md file inside the LibraryProject directory
- Ready to start development server using: `python manage.py runserver`
- Access the application at: `http://127.0.0.1:8000/` to view the default Django welcome page

### Step 4: Explore the Project Structure
- Familiarized with the created project structure and key components

## Key Files and Their Roles

### `settings.py`
**Configuration for the Django project.** This is the central configuration file for your Django project. It contains all the important settings including:
- Database configuration
- Installed applications
- Middleware configuration  
- Template settings
- Static files configuration
- Security settings
- Internationalization settings

### `urls.py`
**The URL declarations for the project; a "table of contents" of your Django-powered site.** This file defines the URL patterns that Django uses to determine which view function to call for each incoming URL request. It acts as a routing system that maps URLs to their corresponding view functions.

### `manage.py`
**A command-line utility that lets you interact with this Django project.** This script provides various administrative tasks and commands for managing your Django project, including:
- Running the development server (`runserver`)
- Creating and applying database migrations
- Creating superusers for admin access
- Collecting static files
- Running tests
- And many more administrative commands

## Additional Project Files

### `wsgi.py`
Web Server Gateway Interface configuration file used for deploying the Django application to production web servers.

### `asgi.py`
Asynchronous Server Gateway Interface configuration file used for handling asynchronous requests and WebSocket connections.

### `__init__.py`
Python package initialization file that makes the LibraryProject directory a Python package.

## Development Workflow

### Starting the Development Server
```bash
python manage.py runserver
```

### Accessing the Application
Open your web browser and navigate to: `http://127.0.0.1:8000/`

You should see the default Django welcome page confirming that your Django project is working correctly.

### Common Django Commands
```bash
# Check for any issues with the project
python manage.py check

# Create database migrations
python manage.py makemigrations

# Apply database migrations  
python manage.py migrate

# Create a superuser for admin access
python manage.py createsuperuser

# Start an interactive Python shell with Django environment
python manage.py shell

# Run project tests
python manage.py test
```

## Project Structure
```
LibraryProject/
├── manage.py                    # Django management script
├── README.md                    # This documentation file
└── LibraryProject/             # Main project package
    ├── __init__.py             # Package initialization
    ├── settings.py             # Project configuration
    ├── urls.py                 # URL routing configuration
    ├── wsgi.py                 # WSGI configuration for deployment
    └── asgi.py                 # ASGI configuration for async support
```

## Repository Information
- **Repository Name:** Alx_DjangoLearnLab
- **Directory:** Introduction_to_Django  
- **Project Name:** LibraryProject
- **Django Version:** Latest stable version installed via pip

## Next Steps

This LibraryProject serves as the foundation for developing Django applications. Future development may include:
- Creating Django applications within the project
- Implementing models for data management
- Creating views and templates for user interfaces
- Adding authentication and authorization
- Implementing API endpoints
- Adding testing coverage

## Task Completion

This project fulfills all requirements of the "Introduction to Django Development Environment Setup" task:
- ✅ Django installed successfully
- ✅ LibraryProject created using django-admin
- ✅ Project directory navigation completed
- ✅ README.md file created within LibraryProject directory
- ✅ Development server ready to run
- ✅ Project structure explored and documented

The Django development environment is now properly set up and ready for further development work.
EOF

echo "✅ README.md created inside LibraryProject directory"

# Display the exact project structure as per task requirements
echo ""
echo "🔟 Step 4: Exploring the Project Structure..."
echo ""
echo "📁 Project Structure (as required by task):"
echo "Alx_DjangoLearnLab/"
echo "└── Introduction_to_Django/"
echo "    ├── django_env/          # Virtual environment"
echo "    └── LibraryProject/      # Django project directory"
echo "        ├── manage.py        # Command-line utility for Django project"
echo "        ├── README.md        # Project documentation"
echo "        └── LibraryProject/  # Project configuration package"
echo "            ├── __init__.py"
echo "            ├── settings.py  # Configuration for Django project"
echo "            ├── urls.py      # URL declarations (table of contents)"
echo "            ├── wsgi.py      # WSGI configuration"
echo "            └── asgi.py      # ASGI configuration"
echo ""

# Test Django installation
echo "1️⃣1️⃣ Testing Django project setup..."
python manage.py check
if [ $? -eq 0 ]; then
    echo "✅ Django project setup is successful!"
else
    echo "⚠️  Some issues found, but project should still work"
fi

echo ""
echo "🎉 Django Development Environment Setup Complete!"
echo "=============================================="
echo ""
echo "📍 Current Location: $(pwd)"
echo "📁 Repository: Alx_DjangoLearnLab/Introduction_to_Django/LibraryProject"
echo "🐍 Virtual Environment: Activated"
echo "🌐 Django Version: $(python -c "import django; print(django.get_version())")"
echo ""
echo "🚀 To complete Step 3 - Run the Development Server:"
echo "   python manage.py runserver"
echo ""
echo "🌍 Then visit: http://127.0.0.1:8000/ to view the default Django welcome page"
echo ""
echo "📋 Task Completion Status:"
echo "   ✅ Step 1: Install Django"
echo "   ✅ Step 2: Create Your Django Project (LibraryProject)"  
echo "   ✅ Step 3: Navigate to project directory & Create README.md"
echo "   🔄 Step 3: Ready to run development server"
echo "   ✅ Step 4: Project structure explored"
echo ""
echo "💡 Key Files Created (as per task requirements):"
echo "   • manage.py     - Command-line utility for Django project interaction"
echo "   • settings.py   - Configuration for the Django project"
echo "   • urls.py       - URL declarations (table of contents)"
echo "   • README.md     - Created inside LibraryProject as specified"
echo ""
echo "Happy Django development! 🎯"
