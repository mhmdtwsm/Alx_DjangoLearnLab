#!/bin/bash

echo "🚀 Django REST Framework Filtering Quick Start"
echo "=" * 50

# Activate virtual environment if it exists
if [ -d "venv" ]; then
    echo "📦 Activating virtual environment..."
    source venv/bin/activate
fi

# Install requirements
echo "📦 Installing requirements..."
pip install -r requirements.txt

# Run migrations
echo "🔄 Running migrations..."
python manage.py makemigrations
python manage.py migrate

# Load sample data
echo "📊 Loading sample data..."
python load_sample_data.py

# Create superuser if it doesn't exist
echo "👤 Creating superuser (if needed)..."
python manage.py shell -c "
from django.contrib.auth.models import User
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print('✅ Superuser created: admin/admin123')
else:
    print('ℹ️ Superuser already exists')
"

echo ""
echo "🎉 Setup complete! You can now:"
echo "1. Start the server: python manage.py runserver"
echo "2. Test the API: ./test_filtering_advanced.py"
echo "3. Access admin: http://127.0.0.1:8000/admin/ (admin/admin123)"
echo "4. API endpoint: http://127.0.0.1:8000/api/books/"
echo ""
echo "📖 Example API calls:"
echo "curl 'http://127.0.0.1:8000/api/books/?search=Django'"
echo "curl 'http://127.0.0.1:8000/api/books/?ordering=-publication_year'"
echo "curl 'http://127.0.0.1:8000/api/books/?author_name=John&publication_year_gte=2023'"
