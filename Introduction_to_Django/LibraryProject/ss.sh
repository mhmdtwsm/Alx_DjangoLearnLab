#!/bin/bash

# Django Models Task 2 - Admin Interface Script
# Task: Utilizing the Django Admin Interface
# Repository: Alx_DjangoLearnLab/Introduction_to_Django

set -e  # Exit on error

echo "🚀 Starting Django Admin Task 2 Implementation..."
echo "=================================================="
echo ""

# Step 1: Register Book model in admin.py
echo "1️⃣  Registering Book model in Django Admin..."

cat > bookshelf/admin.py << 'EOF'
from django.contrib import admin
from .models import Book

@admin.register(Book)
class BookAdmin(admin.ModelAdmin):
    list_display = ("title", "author", "publication_year")   # Show these fields in list view
    list_filter = ("author", "publication_year")             # Add filters in sidebar
    search_fields = ("title", "author")                      # Enable search by title and author
EOF

echo "✅ Book model registered and admin customized with:"
echo "   • list_display: title, author, publication_year"
echo "   • list_filter: author, publication_year"
echo "   • search_fields: title, author"

# Step 2: Create admin documentation file
echo ""
echo "2️⃣  Creating admin documentation file (admin_setup.md)..."

cat > admin_setup.md << 'EOF'
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

