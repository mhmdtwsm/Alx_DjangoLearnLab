from rest_framework import generics
from .models import Book
from .serializers import BookSerializer


class BookList(generics.ListAPIView):
    """
    API view to retrieve a list of all books.
    Uses ListAPIView to provide GET method for listing books.
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer
