"""
Django Admin Configuration for Advanced API Project

This module configures the Django admin interface for our Author and Book models,
providing an easy-to-use interface for managing data during development and testing.
"""

from django.contrib import admin
from .models import Author, Book


@admin.register(Author)
class AuthorAdmin(admin.ModelAdmin):
    """
    Admin configuration for the Author model.
    
    Provides a comprehensive interface for managing authors with
    enhanced display and filtering options.
    """
    
    list_display = ['name', 'book_count']
    search_fields = ['name']
    ordering = ['name']
    
    def book_count(self, obj):
        """Display the number of books by this author."""
        return obj.books.count()
    book_count.short_description = 'Number of Books'


@admin.register(Book)
class BookAdmin(admin.ModelAdmin):
    """
    Admin configuration for the Book model.
    
    Provides a comprehensive interface for managing books with
    enhanced display, filtering, and search options.
    """
    
    list_display = ['title', 'author', 'publication_year']
    list_filter = ['publication_year', 'author']
    search_fields = ['title', 'author__name']
    ordering = ['-publication_year', 'title']
    list_select_related = ['author']  # Optimize database queries
    
    fieldsets = (
        ('Book Information', {
            'fields': ('title', 'publication_year')
        }),
        ('Author Information', {
            'fields': ('author',)
        }),
    )
