#!/bin/bash

echo "🚀 Quick Setup for Permissions System"
echo "====================================="

cd /home/mhmd/study/alx/Alx_DjangoLearnLab/advanced_features_and_security/LibraryProject

echo "📝 Making migrations..."
python manage.py makemigrations bookshelf

echo "🔄 Applying migrations..."
python manage.py migrate

echo "👥 Setting up groups and permissions..."
python manage.py setup_groups

echo "🧪 Creating test users and books..."
python test_permissions.py

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Run: python manage.py runserver"
echo "2. Visit: http://127.0.0.1:8000/books/"
echo "3. Test with different users:"
echo "   - viewer_test / viewers123"
echo "   - editor_test / editors123" 
echo "   - admin_test / admins123"
