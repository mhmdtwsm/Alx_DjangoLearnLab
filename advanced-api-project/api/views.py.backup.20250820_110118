"""
Enhanced API Views with Filtering, Searching, and Ordering.

This module provides comprehensive API views for the Book model with
advanced query capabilities including filtering, searching, and ordering.
"""

from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter
from django.shortcuts import get_object_or_404

from .models import Book
from .serializers import BookSerializer
from .filters import BookFilter


class BookListView(generics.ListCreateAPIView):
    """
    Enhanced Book List View with filtering, searching, and ordering.
    
    Features:
    - **Filtering**: Filter by title, author, and publication_year with various lookup types
    - **Searching**: Search across title and author fields simultaneously  
    - **Ordering**: Sort results by any Book model field
    - **Pagination**: Paginated results for better performance
    
    ## Filtering Options:
    - `title`: Case-insensitive partial match in title
    - `title_exact`: Exact title match
    - `author`: Case-insensitive partial match in author name
    - `author_exact`: Exact author name match
    - `publication_year`: Exact year match
    - `publication_year_gte`: Books published in or after specified year
    - `publication_year_lte`: Books published in or before specified year
    
    ## Search Functionality:
    - `search`: Search across title and author fields
    
    ## Ordering Options:
    - `ordering`: Order by any field (prefix with '-' for descending)
    - Available fields: title, author, publication_year, id
    - Multiple fields: separate with commas (e.g., 'author,title')
    
    ## Usage Examples:
    - `/api/books/?title=django` - Books with 'django' in title
    - `/api/books/?author=smith&publication_year_gte=2020` - Books by authors containing 'smith' from 2020 onwards
    - `/api/books/?search=python&ordering=-publication_year` - Search 'python', newest first
    - `/api/books/?ordering=author,title` - Order by author, then title
    """
    
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    
    # Configure filter backends
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    
    # Filtering configuration
    filterset_class = BookFilter
    
    # Search configuration
    search_fields = ['title', 'author']
    
    # Ordering configuration
    ordering_fields = ['title', 'author', 'publication_year', 'id']
    ordering = ['title']  # Default ordering
    
    def get_queryset(self):
        """
        Optionally apply custom queryset modifications.
        This method can be extended for user-specific filtering or other logic.
        """
        queryset = Book.objects.all()
        
        # Example: Add any additional custom filtering logic here
        # For instance, if books were user-specific:
        # if self.request.user.is_authenticated:
        #     queryset = queryset.filter(owner=self.request.user)
        
        return queryset
    
    def list(self, request, *args, **kwargs):
        """
        List books with applied filters, search, and ordering.
        """
        queryset = self.filter_queryset(self.get_queryset())
        
        # Apply pagination
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            response_data = self.get_paginated_response(serializer.data)
            
            # Add metadata about applied filters
            if hasattr(response_data, 'data') and isinstance(response_data.data, dict):
                response_data.data['applied_filters'] = {
                    'search': request.GET.get('search', None),
                    'ordering': request.GET.get('ordering', 'title'),
                    'filters': {k: v for k, v in request.GET.items() 
                              if k not in ['search', 'ordering', 'page', 'page_size']}
                }
            
            return response_data
        
        serializer = self.get_serializer(queryset, many=True)
        return Response({
            'results': serializer.data,
            'count': queryset.count(),
            'applied_filters': {
                'search': request.GET.get('search', None),
                'ordering': request.GET.get('ordering', 'title'),
                'filters': {k: v for k, v in request.GET.items() 
                          if k not in ['search', 'ordering', 'page', 'page_size']}
            }
        })
    
    def create(self, request, *args, **kwargs):
        """
        Create a new book with enhanced validation and response.
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        
        return Response({
            'message': 'Book created successfully',
            'data': serializer.data
        }, status=status.HTTP_201_CREATED, headers=headers)


class BookDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Retrieve, update, or delete a specific book.
    
    Supports GET, PUT, PATCH, and DELETE operations on individual book instances.
    """
    
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    lookup_field = 'pk'
    
    def retrieve(self, request, *args, **kwargs):
        """
        Retrieve a specific book with enhanced response format.
        """
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        
        return Response({
            'data': serializer.data,
            'message': 'Book retrieved successfully'
        })
    
    def update(self, request, *args, **kwargs):
        """
        Update a book with enhanced validation and response.
        """
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        
        if getattr(instance, '_prefetched_objects_cache', None):
            instance._prefetched_objects_cache = {}
        
        return Response({
            'message': 'Book updated successfully',
            'data': serializer.data
        })
    
    def destroy(self, request, *args, **kwargs):
        """
        Delete a book with confirmation response.
        """
        instance = self.get_object()
        book_title = instance.title
        self.perform_destroy(instance)
        
        return Response({
            'message': f'Book "{book_title}" deleted successfully'
        }, status=status.HTTP_204_NO_CONTENT)


# Additional view for advanced book operations
class BookSearchView(generics.ListAPIView):
    """
    Dedicated search view for advanced book searching.
    
    This view provides enhanced search capabilities with detailed
    search metadata and suggestions.
    """
    
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    filter_backends = [SearchFilter, OrderingFilter]
    search_fields = ['title', 'author']
    ordering_fields = ['title', 'author', 'publication_year']
    ordering = ['title']
    
    def get_queryset(self):
        """
        Get queryset for search operations.
        """
        return Book.objects.all()
    
    def list(self, request, *args, **kwargs):
        """
        Enhanced search with metadata.
        """
        search_term = request.GET.get('search', '')
        
        if not search_term:
            return Response({
                'message': 'Please provide a search term using the "search" parameter',
                'example': '/api/books/search/?search=python'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        queryset = self.filter_queryset(self.get_queryset())
        serializer = self.get_serializer(queryset, many=True)
        
        return Response({
            'search_term': search_term,
            'result_count': queryset.count(),
            'results': serializer.data,
            'search_fields': self.search_fields
        })
