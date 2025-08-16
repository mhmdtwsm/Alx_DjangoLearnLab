#!/bin/bash

# Django LibraryProject Setup Script
# This script creates a Python virtual environment, installs Django, and sets up the LibraryProject

set -e  # Exit on any error

echo "🚀 Starting Django LibraryProject Setup..."
echo "=====================================\n"

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
echo "\n2️⃣  Checking pip installation..."
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

# Create project directory
echo "\n3️⃣  Creating project directory..."
PROJECT_DIR="LibraryProject_Environment"
if [ -d "$PROJECT_DIR" ]; then
    echo "⚠️  Directory $PROJECT_DIR already exists. Removing it..."
    rm -rf "$PROJECT_DIR"
fi
mkdir "$PROJECT_DIR"
cd "$PROJECT_DIR"
echo "✅ Created and moved to $PROJECT_DIR"

# Create virtual environment
echo "\n4️⃣  Creating Python virtual environment..."
$PYTHON_CMD -m venv django_env
echo "✅ Virtual environment 'django_env' created"

# Activate virtual environment
echo "\n5️⃣  Activating virtual environment..."
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

# Upgrade pip
echo "\n6️⃣  Upgrading pip..."
pip install --upgrade pip
echo "✅ pip upgraded"

# Install Django
echo "\n7️⃣  Installing Django..."
pip install django
echo "✅ Django installed successfully"
echo "📦 Django version: $(django-admin --version)"

# Create Django project
echo "\n8️⃣  Creating Django project 'LibraryProject'..."
django-admin startproject LibraryProject
echo "✅ LibraryProject created"

# Navigate to project directory
cd LibraryProject

# Create README.md file
echo "\n9️⃣  Creating README.md file..."
cat > README.md << 'EOF'
# LibraryProject

A Django web application project for managing a library system.

## Setup Instructions

### Prerequisites
- Python 3.x installed
- Virtual environment activated

### Installation
1. Ensure you're in the virtual environment:
   ```bash
   source ../django_env/bin/activate  # On Unix/Linux/MacOS
   # OR
   ..\django_env\Scripts\activate     # On Windows
   ```

2. Install dependencies (if any):
   ```bash
   pip install -r requirements.txt
   ```

### Running the Development Server
```bash
python manage.py runserver
```

Then open your browser and go to: `http://127.0.0.1:8000/`

### Project Structure
- `manage.py`: Command-line utility for interacting with the Django project
- `LibraryProject/settings.py`: Configuration settings for the Django project
- `LibraryProject/urls.py`: URL routing configuration
- `LibraryProject/wsgi.py`: WSGI configuration for deployment
- `LibraryProject/asgi.py`: ASGI configuration for async support

### Useful Commands
- `python manage.py runserver`: Start the development server
- `python manage.py migrate`: Apply database migrations
- `python manage.py createsuperuser`: Create an admin user
- `python manage.py startapp <app_name>`: Create a new Django app
- `python manage.py collectstatic`: Collect static files for production

### Development Workflow
1. Make changes to your code
2. Run migrations if you've changed models: `python manage.py makemigrations` then `python manage.py migrate`
3. Test your changes with `python manage.py runserver`

## Next Steps
- Create Django applications using `python manage.py startapp <app_name>`
- Configure your database settings in `settings.py`
- Create models, views, and templates for your library system
EOF

echo "✅ README.md created with project documentation"

# Create requirements.txt
echo "\n🔟 Creating requirements.txt..."
pip freeze > requirements.txt
echo "✅ requirements.txt created with current dependencies"

# Display project structure
echo "\n1️⃣1️⃣ Project structure created:"
echo "📁 Project Structure:"
if command -v tree &> /dev/null; then
    tree -L 3
else
    find . -type d | head -10 | sed 's|[^/]*/|  |g'
fi

# Test Django installation
echo "\n1️⃣2️⃣ Testing Django installation..."
python manage.py check
if [ $? -eq 0 ]; then
    echo "✅ Django project passes all checks!"
else
    echo "⚠️  Some issues found, but project should still work"
fi

echo "\n🎉 Setup Complete!"
echo "==================="
echo "📍 Location: $(pwd)"
echo "🐍 Virtual Environment: Activated (django_env)"
echo "🌐 Django Version: $(python -c "import django; print(django.get_version())")"
echo ""
echo "🚀 To start your development server:"
echo "   python manage.py runserver"
echo ""
echo "🌍 Then visit: http://127.0.0.1:8000/"
echo ""
echo "📝 Key Files Overview:"
echo "   • manage.py         - Django management commands"
echo "   • settings.py       - Project configuration"  
echo "   • urls.py          - URL routing"
echo "   • README.md        - Project documentation"
echo ""
echo "💡 Pro Tips:"
echo "   • Always activate your virtual environment before working: $ACTIVATE_CMD"
echo "   • Use 'python manage.py help' to see all available commands"
echo "   • Check README.md for detailed instructions and next steps"
echo ""
echo "Happy coding! 🎯"

