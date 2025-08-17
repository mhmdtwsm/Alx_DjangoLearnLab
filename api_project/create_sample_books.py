#!/usr/bin/env python
"""
Script to create sample book data for testing the API.
Run this after setting up your database and running migrations.

Usage: python create_sample_books.py
"""

import os
import django
import sys

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'api_project.settings')
django.setup()

from api.models import Book

def create_sample_books():
    """Create sample books for testing the API."""
    
    sample_books = [
        {
            'title': 'The Django Book',
            'author': 'Adrian Holovaty',
            'publication_year': 2009
        },
        {
            'title': 'Two Scoops of Django',
            'author': 'Daniel Roy Greenfeld',
            'publication_year': 2020
        },
        {
            'title': 'Django for Beginners',
            'author': 'William S. Vincent',
            'publication_year': 2021
        },
        {
            'title': 'Django REST Framework Tutorial',
            'author': 'Test Author',
            'publication_year': 2023
        },
    ]
    
    created_count = 0
    for book_data in sample_books:
        book, created = Book.objects.get_or_create(
            title=book_data['title'],
            defaults=book_data
        )
        if created:
            created_count += 1
            print(f"✓ Created book: {book.title}")
        else:
            print(f"- Book already exists: {book.title}")
    
    print(f"\nSummary: {created_count} new books created.")
    print(f"Total books in database: {Book.objects.count()}")

if __name__ == '__main__':
    try:
        create_sample_books()
    except Exception as e:
        print(f"Error creating sample books: {e}")
        sys.exit(1)
