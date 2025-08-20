#!/usr/bin/env python3
"""
Load sample data for testing filtering functionality.
"""

import os
import sys
import django

# Add the project directory to the Python path
sys.path.append('/home/mhmd/study/alx/Alx_DjangoLearnLab/advanced-api-project')

# Set up Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'advanced_api_project.settings')
django.setup()

from api.models import Book, Author

def load_sample_data():
    """Load sample books and authors for testing."""
    print("🔄 Loading sample data...")
    
    # Clear existing data
    Book.objects.all().delete()
    Author.objects.all().delete()
    
    # Create authors
    authors_data = [
        "John Smith",
        "Jane Doe", 
        "Robert Johnson",
        "Emily Brown",
        "Michael Davis",
        "Sarah Wilson",
        "David Miller",
        "Lisa Anderson"
    ]
    
    authors = []
    for name in authors_data:
        author = Author.objects.create(name=name)
        authors.append(author)
        print(f"✅ Created author: {name}")
    
    # Create books
    books_data = [
        ("Django for Beginners", authors[0], 2023),
        ("Advanced Django Techniques", authors[0], 2024),
        ("Python Programming Basics", authors[1], 2022),
        ("Web Development with Django", authors[2], 2023),
        ("RESTful APIs with Django", authors[1], 2024),
        ("Database Design Principles", authors[3], 2021),
        ("JavaScript for Web Developers", authors[4], 2022),
        ("Modern CSS Techniques", authors[5], 2023),
        ("React and Django Integration", authors[2], 2024),
        ("Machine Learning with Python", authors[6], 2023),
        ("Data Science Fundamentals", authors[7], 2022),
        ("Django Security Best Practices", authors[0], 2024),
        ("API Development Guide", authors[3], 2023),
        ("Full-Stack Development", authors[4], 2024),
        ("Python Testing Strategies", authors[1], 2023),
        ("Docker for Developers", authors[5], 2022),
        ("Cloud Computing Basics", authors[6], 2023),
        ("DevOps with Python", authors[7], 2024),
        ("Microservices Architecture", authors[2], 2023),
        ("GraphQL and Django", authors[0], 2024)
    ]
    
    for title, author, year in books_data:
        book = Book.objects.create(
            title=title,
            author=author,
            publication_year=year
        )
        print(f"✅ Created book: {title} by {author.name} ({year})")
    
    print(f"\n🎉 Successfully loaded {len(authors)} authors and {len(books_data)} books!")
    print("\n📊 Data Summary:")
    print(f"Authors: {Author.objects.count()}")
    print(f"Books: {Book.objects.count()}")
    
    # Show some statistics
    print(f"\n📚 Books by year:")
    years = Book.objects.values_list('publication_year', flat=True).distinct().order_by('publication_year')
    for year in years:
        count = Book.objects.filter(publication_year=year).count()
        print(f"  {year}: {count} books")

if __name__ == '__main__':
    load_sample_data()
