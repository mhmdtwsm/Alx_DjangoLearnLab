"""
Serializers for the Advanced API Project

This module contains custom Django REST Framework serializers that handle
complex data structures and nested relationships between Author and Book models.

The serializers demonstrate advanced DRF concepts including:
- Custom validation methods
- Nested serialization of related objects
- Dynamic field handling
- Data transformation and representation

Serializers:
- BookSerializer: Handles Book model serialization with custom validation
- AuthorSerializer: Handles Author model with nested Book serialization
"""

from rest_framework import serializers
from datetime import datetime
from .models import Author, Book


class BookSerializer(serializers.ModelSerializer):
    """
    Custom serializer for the Book model.
    
    This serializer handles the serialization and deserialization of Book instances,
    including custom validation to ensure data integrity.
    
    Features:
    - Serializes all fields of the Book model
    - Custom validation for publication_year to prevent future dates
    - Proper handling of the author relationship
    
    Validation Rules:
    - publication_year cannot be in the future
    - All required fields must be provided
    """
    
    class Meta:
        model = Book
        fields = ['id', 'title', 'publication_year', 'author']
    
    def validate_publication_year(self, value):
        """
        Custom validation method for publication_year field.
        
        Ensures that the publication year is not in the future, as books
        cannot be published in years that haven't occurred yet.
        
        Args:
            value (int): The publication year to validate
            
        Returns:
            int: The validated publication year
            
        Raises:
            serializers.ValidationError: If the year is in the future
        """
        current_year = datetime.now().year
        
        if value > current_year:
            raise serializers.ValidationError(
                f"Publication year cannot be in the future. "
                f"Current year is {current_year}, but got {value}."
            )
        
        # Additional validation: reasonable minimum year
        if value < 1000:
            raise serializers.ValidationError(
                "Publication year seems too old. Please provide a reasonable year."
            )
        
        return value
    
    def validate(self, data):
        """
        Object-level validation for the entire Book instance.
        
        This method performs validation that requires access to multiple fields
        or complex business logic validation.
        
        Args:
            data (dict): Dictionary of field values to validate
            
        Returns:
            dict: Validated data dictionary
            
        Raises:
            serializers.ValidationError: If validation fails
        """
        # Example of object-level validation
        title = data.get('title', '').strip()
        if not title:
            raise serializers.ValidationError({
                'title': 'Book title cannot be empty or just whitespace.'
            })
        
        # Ensure title has reasonable length
        if len(title) < 2:
            raise serializers.ValidationError({
                'title': 'Book title must be at least 2 characters long.'
            })
        
        return data


class AuthorSerializer(serializers.ModelSerializer):
    """
    Custom serializer for the Author model with nested Book serialization.
    
    This serializer demonstrates advanced DRF concepts by including nested
    serialization of related Book objects. It dynamically includes all books
    written by the author using the reverse foreign key relationship.
    
    Features:
    - Serializes the Author's name field
    - Includes nested serialization of all related books
    - Uses the BookSerializer for consistent book representation
    - Handles the one-to-many relationship between Author and Books
    
    Nested Relationships:
    The 'books' field uses the related_name='books' defined in the Book model's
    foreign key relationship. This allows us to access all books by an author
    through the reverse relationship.
    """
    
    # Nested serializer field that includes all books by this author
    # The 'many=True' parameter indicates this is a one-to-many relationship
    # 'read_only=True' means this field won't be used for deserialization
    books = BookSerializer(many=True, read_only=True)
    
    class Meta:
        model = Author
        fields = ['id', 'name', 'books']
    
    def validate_name(self, value):
        """
        Custom validation method for the author name field.
        
        Ensures that author names meet basic quality standards.
        
        Args:
            value (str): The author name to validate
            
        Returns:
            str: The validated and cleaned author name
            
        Raises:
            serializers.ValidationError: If the name doesn't meet requirements
        """
        # Clean the name by stripping whitespace
        cleaned_name = value.strip()
        
        if not cleaned_name:
            raise serializers.ValidationError(
                "Author name cannot be empty or just whitespace."
            )
        
        if len(cleaned_name) < 2:
            raise serializers.ValidationError(
                "Author name must be at least 2 characters long."
            )
        
        # Check for reasonable maximum length
        if len(cleaned_name) > 100:
            raise serializers.ValidationError(
                "Author name is too long. Maximum 100 characters allowed."
            )
        
        return cleaned_name
    
    def to_representation(self, instance):
        """
        Custom method to control how the serialized data is represented.
        
        This method allows us to customize the output format and add
        additional computed fields or modify existing ones.
        
        Args:
            instance (Author): The Author instance being serialized
            
        Returns:
            dict: The serialized representation of the author
        """
        # Get the default representation
        representation = super().to_representation(instance)
        
        # Add a computed field showing the number of books
        representation['book_count'] = len(representation['books'])
        
        # Add the most recent publication year if books exist
        if representation['books']:
            latest_year = max(book['publication_year'] for book in representation['books'])
            representation['latest_publication_year'] = latest_year
        else:
            representation['latest_publication_year'] = None
        
        return representation


# Alternative simplified serializer for cases where nested data isn't needed
class AuthorBasicSerializer(serializers.ModelSerializer):
    """
    Basic serializer for Author model without nested books.
    
    This serializer provides a lightweight representation of authors
    without the overhead of loading and serializing all related books.
    Useful for list views or when only basic author information is needed.
    """
    
    book_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Author
        fields = ['id', 'name', 'book_count']
    
    def get_book_count(self, obj):
        """
        SerializerMethodField to get the count of books by this author.
        
        Args:
            obj (Author): The author instance
            
        Returns:
            int: Number of books written by this author
        """
        return obj.books.count()
