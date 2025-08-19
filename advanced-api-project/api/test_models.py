"""
Test script for manually testing models and serializers.

This script can be run in Django shell to test the functionality
of our models and serializers.

Usage:
    python manage.py shell
    exec(open('api/test_models.py').read())
"""

from datetime import datetime
from api.models import Author, Book
from api.serializers import AuthorSerializer, BookSerializer

def test_models_and_serializers():
    """
    Test function to verify models and serializers work correctly.
    """
    print("🧪 Testing Models and Serializers...")
    
    # Test creating an author
    print("\n📝 Creating test author...")
    author = Author.objects.create(name="J.K. Rowling")
    print(f"✅ Created author: {author}")
    
    # Test creating books
    print("\n📚 Creating test books...")
    book1 = Book.objects.create(
        title="Harry Potter and the Philosopher's Stone",
        publication_year=1997,
        author=author
    )
    book2 = Book.objects.create(
        title="Harry Potter and the Chamber of Secrets",
        publication_year=1998,
        author=author
    )
    print(f"✅ Created books: {book1}, {book2}")
    
    # Test BookSerializer
    print("\n🔄 Testing BookSerializer...")
    book_serializer = BookSerializer(book1)
    print(f"Book serialized data: {book_serializer.data}")
    
    # Test AuthorSerializer with nested books
    print("\n🔄 Testing AuthorSerializer...")
    author_serializer = AuthorSerializer(author)
    print(f"Author serialized data: {author_serializer.data}")
    
    # Test validation
    print("\n✅ Testing custom validation...")
    try:
        future_year = datetime.now().year + 1
        invalid_book_data = {
            'title': 'Future Book',
            'publication_year': future_year,
            'author': author.id
        }
        book_serializer = BookSerializer(data=invalid_book_data)
        if not book_serializer.is_valid():
            print(f"✅ Validation working correctly. Errors: {book_serializer.errors}")
        else:
            print("❌ Validation should have failed for future year")
    except Exception as e:
        print(f"❌ Error during validation test: {e}")
    
    print("\n🎉 All tests completed!")

# Run tests if executed directly
if __name__ == "__main__":
    test_models_and_serializers()
