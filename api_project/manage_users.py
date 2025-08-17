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
