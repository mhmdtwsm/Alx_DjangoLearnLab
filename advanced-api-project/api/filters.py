"""
Custom filters for the Book API.

This module defines filtering capabilities for the Book model,
allowing users to filter books by various attributes with different
lookup types for enhanced API usability.
"""

import django_filters
from .models import Book


class BookFilter(django_filters.FilterSet):
    """
    Comprehensive filter set for the Book model.
    
    Provides multiple filtering options:
    - Title filtering (exact match and case-insensitive contains)
    - Author filtering (exact match and case-insensitive contains)
    - Publication year filtering (exact, range, greater than, less than)
    """
    
    # Title filters
    title = django_filters.CharFilter(
        lookup_expr='icontains',
        help_text="Filter by title containing the specified text (case-insensitive)"
    )
    title_exact = django_filters.CharFilter(
        field_name='title',
        lookup_expr='exact',
        help_text="Filter by exact title match"
    )
    
    # Author filters
    author = django_filters.CharFilter(
        lookup_expr='icontains',
        help_text="Filter by author name containing the specified text (case-insensitive)"
    )
    author_exact = django_filters.CharFilter(
        field_name='author',
        lookup_expr='exact',
        help_text="Filter by exact author name match"
    )
    
    # Publication year filters
    publication_year = django_filters.NumberFilter(
        help_text="Filter by exact publication year"
    )
    publication_year_gte = django_filters.NumberFilter(
        field_name='publication_year',
        lookup_expr='gte',
        help_text="Filter books published in or after the specified year"
    )
    publication_year_lte = django_filters.NumberFilter(
        field_name='publication_year',
        lookup_expr='lte',
        help_text="Filter books published in or before the specified year"
    )
    publication_year_range = django_filters.RangeFilter(
        field_name='publication_year',
        help_text="Filter books published within a year range (use publication_year_range_min and publication_year_range_max)"
    )
    
    class Meta:
        model = Book
        fields = {
            'title': ['exact', 'icontains'],
            'author': ['exact', 'icontains'], 
            'publication_year': ['exact', 'gte', 'lte', 'range'],
        }
        
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Add custom help text for better API documentation
        for field_name, field in self.filters.items():
            if hasattr(field, 'extra'):
                field.extra.setdefault('help_text', f'Filter by {field_name}')
