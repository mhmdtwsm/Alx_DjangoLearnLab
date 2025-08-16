from django.contrib import admin
from .models import Book

@admin.register(Book)
class BookAdmin(admin.ModelAdmin):
    list_display = ("title", "author", "publication_year")   # Show these fields in list view
    list_filter = ("author", "publication_year")             # Add filters in sidebar
    search_fields = ("title", "author")                      # Enable search by title and author
