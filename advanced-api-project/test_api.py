#!/usr/bin/env python
"""
API Testing Script for Django REST Framework Generic Views
This script tests all CRUD operations with and without authentication.
"""

import requests
import json
import sys

BASE_URL = 'http://127.0.0.1:8000/api'
AUTH_URL = 'http://127.0.0.1:8000/api-token-auth/'

def get_auth_token():
    """Get authentication token for testuser"""
    data = {
        'username': 'testuser',
        'password': 'testpass123'
    }
    try:
        response = requests.post(AUTH_URL, data=data)
        if response.status_code == 200:
            return response.json()['token']
        else:
            print(f"Failed to get token: {response.status_code}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Error getting token: {e}")
        return None

def test_list_books():
    """Test listing all books (no auth required)"""
    print("\n📚 Testing Book List (GET /api/books/)")
    try:
        response = requests.get(f"{BASE_URL}/books/")
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            books = response.json()
            print(f"Found {len(books)} books")
            for book in books[:3]:  # Show first 3
                print(f"  - {book['title']} by {book['author']}")
        else:
            print(f"Error: {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")

def test_book_detail(book_id=1):
    """Test getting a specific book (no auth required)"""
    print(f"\n📖 Testing Book Detail (GET /api/books/{book_id}/)")
    try:
        response = requests.get(f"{BASE_URL}/books/{book_id}/")
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            book = response.json()
            print(f"Book: {book['title']} by {book['author']}")
        else:
            print(f"Error: {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")

def test_create_book(token):
    """Test creating a new book (auth required)"""
    print("\n➕ Testing Book Creation (POST /api/books/create/)")
    headers = {'Authorization': f'Token {token}'}
    data = {
        'title': 'Test Book from API',
        'author': 'API Tester'
    }
    try:
        response = requests.post(f"{BASE_URL}/books/create/", json=data, headers=headers)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 201:
            result = response.json()
            print(f"Created: {result}")
            return result['data']['id']
        else:
            print(f"Error: {response.text}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return None

def test_update_book(book_id, token):
    """Test updating a book (auth required)"""
    print(f"\n✏️  Testing Book Update (PUT /api/books/{book_id}/update/)")
    headers = {'Authorization': f'Token {token}'}
    data = {
        'title': 'Updated Test Book',
        'author': 'Updated API Tester'
    }
    try:
        response = requests.put(f"{BASE_URL}/books/{book_id}/update/", json=data, headers=headers)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Updated: {result}")
        else:
            print(f"Error: {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")

def test_delete_book(book_id, token):
    """Test deleting a book (auth required)"""
    print(f"\n🗑️  Testing Book Deletion (DELETE /api/books/{book_id}/delete/)")
    headers = {'Authorization': f'Token {token}'}
    try:
        response = requests.delete(f"{BASE_URL}/books/{book_id}/delete/", headers=headers)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Deleted: {result}")
        else:
            print(f"Error: {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")

def test_unauthorized_operations():
    """Test operations without authentication"""
    print("\n🚫 Testing Unauthorized Operations")
    
    # Try to create without auth
    data = {'title': 'Unauthorized Book', 'author': 'No Auth'}
    response = requests.post(f"{BASE_URL}/books/create/", json=data)
    print(f"Create without auth - Status: {response.status_code}")
    
    # Try to update without auth
    data = {'title': 'Updated Title'}
    response = requests.put(f"{BASE_URL}/books/1/update/", json=data)
    print(f"Update without auth - Status: {response.status_code}")
    
    # Try to delete without auth
    response = requests.delete(f"{BASE_URL}/books/1/delete/")
    print(f"Delete without auth - Status: {response.status_code}")

def main():
    print("🧪 Starting API Tests...")
    
    # Test read operations (no auth required)
    test_list_books()
    test_book_detail()
    
    # Test unauthorized operations
    test_unauthorized_operations()
    
    # Get authentication token
    print("\n🔑 Getting authentication token...")
    token = get_auth_token()
    if not token:
        print("❌ Could not get authentication token. Make sure to run:")
        print("   python manage.py create_test_data")
        sys.exit(1)
    
    print(f"✅ Got token: {token[:20]}...")
    
    # Test authenticated operations
    created_book_id = test_create_book(token)
    if created_book_id:
        test_update_book(created_book_id, token)
        test_delete_book(created_book_id, token)
    
    print("\n🎉 API tests completed!")

if __name__ == '__main__':
    main()
