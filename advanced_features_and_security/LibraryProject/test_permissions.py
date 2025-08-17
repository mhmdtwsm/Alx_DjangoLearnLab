#!/usr/bin/env python
"""
Test script for permissions system
Run this script to create test users and verify permissions
"""
import os
import sys
import django

# Setup Django environment
sys.path.insert(0, '/home/mhmd/study/alx/Alx_DjangoLearnLab/advanced_features_and_security/LibraryProject')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'LibraryProject.settings')
django.setup()

from django.contrib.auth.models import Group, User
from bookshelf.models import CustomUser, Book, Library

def create_test_users():
    """Create test users for different groups"""
    print("Creating test users...")
    
    # Get or create groups
    viewers_group, _ = Group.objects.get_or_create(name='Viewers')
    editors_group, _ = Group.objects.get_or_create(name='Editors')
    admins_group, _ = Group.objects.get_or_create(name='Admins')
    
    # Create test users
    users_data = [
        ('viewer_test', 'viewer@test.com', 'viewers123', viewers_group),
        ('editor_test', 'editor@test.com', 'editors123', editors_group),
        ('admin_test', 'admin@test.com', 'admins123', admins_group),
    ]
    
    for username, email, password, group in users_data:
        try:
            if hasattr(django.contrib.auth, 'get_user_model'):
                User = django.contrib.auth.get_user_model()
            else:
                from django.contrib.auth.models import User
                
            user, created = User.objects.get_or_create(
                username=username,
                defaults={'email': email}
            )
            if created:
                user.set_password(password)
                user.save()
                user.groups.add(group)
                print(f"✅ Created user: {username} (Group: {group.name})")
            else:
                print(f"👤 User {username} already exists")
        except Exception as e:
            print(f"❌ Error creating user {username}: {e}")

def create_test_books():
    """Create some test books"""
    print("Creating test books...")
    
    books_data = [
        ("The Django Book", "Adrian Holovaty", 2023, "978-0123456789"),
        ("Python Programming", "John Smith", 2022, "978-0987654321"),
        ("Web Development Guide", "Jane Doe", 2024, "978-0456789123"),
    ]
    
    for title, author, year, isbn in books_data:
        book, created = Book.objects.get_or_create(
            isbn=isbn,
            defaults={
                'title': title,
                'author': author,
                'publication_year': year,
                'pages': 200
            }
        )
        if created:
            print(f"📚 Created book: {title}")
        else:
            print(f"📖 Book {title} already exists")

def display_test_info():
    """Display information about test users and login instructions"""
    print("\n" + "="*50)
    print("PERMISSIONS TESTING SETUP COMPLETE")
    print("="*50)
    print("\nTest Users Created:")
    print("1. Username: viewer_test, Password: viewers123 (Viewers Group)")
    print("2. Username: editor_test, Password: editors123 (Editors Group)")  
    print("3. Username: admin_test, Password: admins123 (Admins Group)")
    
    print("\nTo test permissions:")
    print("1. Run migrations: python manage.py makemigrations && python manage.py migrate")
    print("2. Setup groups: python manage.py setup_groups")
    print("3. Start server: python manage.py runserver")
    print("4. Visit: http://127.0.0.1:8000/books/")
    print("5. Login with different users to test permissions")
    
    print("\nExpected Behavior:")
    print("- viewer_test: Can only view books")
    print("- editor_test: Can view, create, edit books")
    print("- admin_test: Can view, create, edit, delete books")

if __name__ == "__main__":
    create_test_users()
    create_test_books()
    display_test_info()
