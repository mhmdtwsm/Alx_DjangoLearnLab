# CRUD Operations Documentation

This document contains all CRUD (Create, Read, Update, Delete) operations performed on the Book model in the Django shell.

## Prerequisites

Before running these commands, ensure you have:
1. Created the `bookshelf` app: `python manage.py startapp bookshelf`
2. Defined the Book model in `bookshelf/models.py`
3. Added `bookshelf` to `INSTALLED_APPS` in `settings.py`
4. Created and applied migrations:
   - `python manage.py makemigrations bookshelf`
   - `python manage.py migrate`
5. Started the Django shell: `python manage.py shell`

## Complete CRUD Workflow

### 1. CREATE Operation

```python
# Import the Book model
from bookshelf.models import Book

# Create a new Book instance
book = Book(title="1984", author="George Orwell", publication_year=1949)

# Save the book to the database
book.save()

# Verify creation
print(f"Book created: {book.title} by {book.author} ({book.publication_year})")
print(f"Book ID: {book.id}")
```

**Output:**
```
Book created: 1984 by George Orwell (1949)
Book ID: 1
```

### 2. RETRIEVE Operation

```python
# Retrieve the book by title
book = Book.objects.get(title="1984")

# Display all attributes
print(f"ID: {book.id}")
print(f"Title: {book.title}")
print(f"Author: {book.author}")
print(f"Publication Year: {book.publication_year}")

# Get all books
all_books = Book.objects.all()
print(f"Total books: {all_books.count()}")
for book in all_books:
    print(f"Book: {book}")
```

**Output:**
```
ID: 1
Title: 1984
Author: George Orwell
Publication Year: 1949
Total books: 1
Book: 1984
```

### 3. UPDATE Operation

```python
# Retrieve the book to update
book = Book.objects.get(title="1984")

# Display current title
print(f"Current title: {book.title}")

# Update the title
book.title = "Nineteen Eighty-Four"

# Save the changes
book.save()

# Verify the update
print(f"Updated title: {book.title}")

# Confirm persistence
updated_book = Book.objects.get(id=book.id)
print(f"Title from database: {updated_book.title}")
```

**Output:**
```
Current title: 1984
Updated title: Nineteen Eighty-Four
Title from database: Nineteen Eighty-Four
```

### 4. DELETE Operation

```python
# Retrieve the book to delete
book = Book.objects.get(title="Nineteen Eighty-Four")

# Display book details before deletion
print(f"Book to delete: {book.title} by {book.author} ({book.publication_year})")

# Delete the book
book.delete()
print("Book deleted successfully")

# Confirm deletion
all_books = Book.objects.all()
print(f"Total books after deletion: {all_books.count()}")

# Verify deletion by attempting retrieval
try:
    deleted_book = Book.objects.get(title="Nineteen Eighty-Four")
except Book.DoesNotExist:
    print("Confirmed: Book has been successfully deleted")
```

**Output:**
```
Book to delete: Nineteen Eighty-Four by George Orwell (1949)
Book deleted successfully
Total books after deletion: 0
Confirmed: Book has been successfully deleted
```

## Summary

All CRUD operations have been successfully demonstrated:
- ✅ **CREATE**: Created a Book instance with title "1984", author "George Orwell", publication year 1949
- ✅ **RETRIEVE**: Retrieved and displayed all attributes of the created book
- ✅ **UPDATE**: Updated the book title from "1984" to "Nineteen Eighty-Four"
- ✅ **DELETE**: Deleted the book and confirmed the deletion

## Model Definition

The Book model used for these operations:

```python
from django.db import models

class Book(models.Model):
    title = models.CharField(max_length=200)
    author = models.CharField(max_length=100)
    publication_year = models.IntegerField()
    
    def __str__(self):
        return self.title
```

## Key Django ORM Methods Used

- `Book()` - Create model instance
- `save()` - Save instance to database
- `objects.get()` - Retrieve single object
- `objects.all()` - Retrieve all objects
- `objects.filter()` - Filter objects by criteria
- `delete()` - Delete object from database
- `DoesNotExist` - Exception for non-existent objects
