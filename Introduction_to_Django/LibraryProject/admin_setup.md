# Django Admin Setup for Book Model

## Objective
Enable and customize the Django admin interface for managing `Book` objects in the `bookshelf` app.

## Steps Implemented
1. Registered the `Book` model in `bookshelf/admin.py`.
2. Customized the admin view with:
   - **list_display**: Shows `title`, `author`, and `publication_year` in the admin list view.
   - **list_filter**: Allows filtering by `author` and `publication_year`.
   - **search_fields**: Enables search by `title` and `author`.

## Code in `bookshelf/admin.py`

```python
from django.contrib import admin
from .models import Book

@admin.register(Book)
class BookAdmin(admin.ModelAdmin):
    list_display = ("title", "author", "publication_year")
    list_filter = ("author", "publication_year")
    search_fields = ("title", "author")

