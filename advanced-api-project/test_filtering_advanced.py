#!/usr/bin/env python3
"""
Comprehensive test suite for Django REST Framework filtering, searching, and ordering functionality.
"""

import os
import sys
import django
import requests
import json
from datetime import datetime

# Add the project directory to the Python path
sys.path.append('/home/mhmd/study/alx/Alx_DjangoLearnLab/advanced-api-project')

# Set up Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'advanced_api_project.settings')
django.setup()

from django.test import TestCase, Client
from django.urls import reverse
from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from django.contrib.auth.models import User
from api.models import Book, Author


class FilteringTestCase(APITestCase):
    """Test filtering, searching, and ordering functionality."""
    
    def setUp(self):
        """Set up test data."""
        self.client = APIClient()
        
        # Create test authors
        self.author1 = Author.objects.create(name="John Doe")
        self.author2 = Author.objects.create(name="Jane Smith")
        self.author3 = Author.objects.create(name="Bob Johnson")
        
        # Create test books
        self.book1 = Book.objects.create(
            title="Django for Beginners",
            author=self.author1,
            publication_year=2023
        )
        self.book2 = Book.objects.create(
            title="Advanced Django",
            author=self.author1,
            publication_year=2024
        )
        self.book3 = Book.objects.create(
            title="Python Programming",
            author=self.author2,
            publication_year=2022
        )
        self.book4 = Book.objects.create(
            title="Web Development",
            author=self.author3,
            publication_year=2023
        )
        
    def test_filtering_by_title(self):
        """Test filtering books by title."""
        print("🔍 Testing title filtering...")
        
        # Test exact title match
        response = self.client.get('/api/books/', {'title': 'Django for Beginners'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(len(data['data']), 1)
        self.assertEqual(data['data'][0]['title'], 'Django for Beginners')
        print("✅ Exact title filtering works")
        
        # Test title contains
        response = self.client.get('/api/books/', {'title_contains': 'Django'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(len(data['data']), 2)
        print("✅ Title contains filtering works")
        
    def test_filtering_by_author(self):
        """Test filtering books by author."""
        print("🔍 Testing author filtering...")
        
        # Test filtering by author ID
        response = self.client.get('/api/books/', {'author': self.author1.id})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(len(data['data']), 2)
        print("✅ Author ID filtering works")
        
        # Test filtering by author name
        response = self.client.get('/api/books/', {'author_name': 'John'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(len(data['data']), 2)
        print("✅ Author name filtering works")
        
    def test_filtering_by_publication_year(self):
        """Test filtering books by publication year."""
        print("🔍 Testing publication year filtering...")
        
        # Test exact year
        response = self.client.get('/api/books/', {'publication_year': 2023})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(len(data['data']), 2)
        print("✅ Exact year filtering works")
        
        # Test year greater than or equal
        response = self.client.get('/api/books/', {'publication_year_gte': 2023})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(len(data['data']), 3)
        print("✅ Year >= filtering works")
        
        # Test year less than or equal
        response = self.client.get('/api/books/', {'publication_year_lte': 2023})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(len(data['data']), 3)
        print("✅ Year <= filtering works")
        
    def test_search_functionality(self):
        """Test search functionality."""
        print("🔍 Testing search functionality...")
        
        # Search in title
        response = self.client.get('/api/books/', {'search': 'Django'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(len(data['data']), 2)
        print("✅ Title search works")
        
        # Search in author name
        response = self.client.get('/api/books/', {'search': 'Jane'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(len(data['data']), 1)
        print("✅ Author search works")
        
    def test_ordering_functionality(self):
        """Test ordering functionality."""
        print("🔍 Testing ordering functionality...")
        
        # Order by title ascending
        response = self.client.get('/api/books/', {'ordering': 'title'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        titles = [book['title'] for book in data['data']]
        self.assertEqual(titles, sorted(titles))
        print("✅ Ascending title ordering works")
        
        # Order by title descending
        response = self.client.get('/api/books/', {'ordering': '-title'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        titles = [book['title'] for book in data['data']]
        self.assertEqual(titles, sorted(titles, reverse=True))
        print("✅ Descending title ordering works")
        
        # Order by publication year
        response = self.client.get('/api/books/', {'ordering': 'publication_year'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        years = [book['publication_year'] for book in data['data']]
        self.assertEqual(years, sorted(years))
        print("✅ Publication year ordering works")
        
    def test_combined_filtering(self):
        """Test combining multiple filters."""
        print("🔍 Testing combined filtering...")
        
        # Combine author and year filtering
        response = self.client.get('/api/books/', {
            'author': self.author1.id,
            'publication_year_gte': 2023
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(len(data['data']), 2)
        print("✅ Combined filtering works")
        
        # Combine search and ordering
        response = self.client.get('/api/books/', {
            'search': 'Django',
            'ordering': '-publication_year'
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(len(data['data']), 2)
        years = [book['publication_year'] for book in data['data']]
        self.assertEqual(years, sorted(years, reverse=True))
        print("✅ Search + ordering works")


def run_live_api_tests():
    """Run tests against the live API server."""
    print("\n🌐 Running live API tests...")
    print("Make sure the Django server is running on http://127.0.0.1:8000/")
    
    base_url = "http://127.0.0.1:8000/api/books/"
    
    test_cases = [
        {
            'name': 'Basic List',
            'url': base_url,
            'expected_keys': ['message', 'data', 'filters_applied']
        },
        {
            'name': 'Title Filtering',
            'url': f"{base_url}?title_contains=Django",
            'expected_keys': ['message', 'data', 'filters_applied']
        },
        {
            'name': 'Search Functionality',
            'url': f"{base_url}?search=Python",
            'expected_keys': ['message', 'data', 'filters_applied']
        },
        {
            'name': 'Ordering',
            'url': f"{base_url}?ordering=-publication_year",
            'expected_keys': ['message', 'data', 'filters_applied']
        },
        {
            'name': 'Year Range Filtering',
            'url': f"{base_url}?publication_year_gte=2023",
            'expected_keys': ['message', 'data', 'filters_applied']
        },
        {
            'name': 'Combined Filters',
            'url': f"{base_url}?search=Django&ordering=title&publication_year_gte=2023",
            'expected_keys': ['message', 'data', 'filters_applied']
        }
    ]
    
    for test_case in test_cases:
        try:
            print(f"\n🧪 Testing: {test_case['name']}")
            print(f"URL: {test_case['url']}")
            
            response = requests.get(test_case['url'], timeout=5)
            
            if response.status_code == 200:
                data = response.json()
                print(f"✅ Status: {response.status_code}")
                print(f"📊 Response keys: {list(data.keys())}")
                
                if 'data' in data:
                    print(f"📚 Books returned: {len(data['data'])}")
                
                if 'filters_applied' in data:
                    print(f"🔍 Filters applied: {data['filters_applied']}")
                    
                # Pretty print first book if available
                if 'data' in data and len(data['data']) > 0:
                    first_book = data['data'][0]
                    print(f"📖 First book: {first_book.get('title', 'N/A')} by {first_book.get('author_name', 'N/A')} ({first_book.get('publication_year', 'N/A')})")
                    
            else:
                print(f"❌ Status: {response.status_code}")
                print(f"Error: {response.text}")
                
        except requests.exceptions.RequestException as e:
            print(f"❌ Connection error: {e}")
            print("Make sure the Django development server is running!")


if __name__ == '__main__':
    print("🚀 Starting Django REST Framework Filtering Tests")
    print("=" * 60)
    
    # Run Django unit tests
    print("\n📋 Running Django Unit Tests...")
    from django.test.utils import get_runner
    from django.conf import settings
    
    test_runner = get_runner(settings)()
    test_suite = test_runner.setup_test_environment()
    
    # Create a test suite with our custom test case
    import unittest
    suite = unittest.TestLoader().loadTestsFromTestCase(FilteringTestCase)
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Run live API tests
    run_live_api_tests()
    
    print("\n" + "=" * 60)
    if result.wasSuccessful():
        print("🎉 All tests passed successfully!")
    else:
        print("❌ Some tests failed. Check the output above.")
    
    print("\n📚 API Documentation Examples:")
    print("=" * 40)
    examples = [
        "GET /api/books/ - List all books",
        "GET /api/books/?title_contains=Django - Search titles containing 'Django'",
        "GET /api/books/?author_name=John - Filter by author name containing 'John'",
        "GET /api/books/?publication_year=2023 - Filter by publication year",
        "GET /api/books/?publication_year_gte=2023 - Books from 2023 onwards",
        "GET /api/books/?search=Python - Search in title and author",
        "GET /api/books/?ordering=title - Order by title ascending",
        "GET /api/books/?ordering=-publication_year - Order by year descending",
        "GET /api/books/?search=Django&ordering=title - Search + ordering",
    ]
    
    for example in examples:
        print(f"  {example}")
