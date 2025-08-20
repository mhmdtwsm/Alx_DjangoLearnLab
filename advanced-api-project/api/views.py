from rest_framework import generics, filters
from django_filters import rest_framework as django_filters
from .models import Book
from .serializers import BookSerializer
from .filters import BookFilter


class BookListView(generics.ListCreateAPIView):
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    filter_backends = [
        django_filters.DjangoFilterBackend,
        filters.SearchFilter,
        filters.OrderingFilter,
    ]
    filterset_class = BookFilter
    search_fields = ["title", "author"]
    ordering_fields = ["title", "publication_year"]


class BookDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Book.objects.all()
    serializer_class = BookSerializer
