from rest_framework import serializers
from .models import Book


class BookSerializer(serializers.ModelSerializer):
    """
    Serializer for Book model.
    Converts Book model instances to JSON format and vice versa.
    """
    class Meta:
        model = Book
        fields = '__all__'  # Include all fields from the Book model
        
    def validate_title(self, value):
        """
        Custom validation for book title.
        """
        if not value or len(value.strip()) == 0:
            raise serializers.ValidationError("Title cannot be empty.")
        return value
        
    def validate_publication_year(self, value):
        """
        Custom validation for publication year.
        """
        import datetime
        current_year = datetime.datetime.now().year
        if value > current_year:
            raise serializers.ValidationError("Publication year cannot be in the future.")
        return value
