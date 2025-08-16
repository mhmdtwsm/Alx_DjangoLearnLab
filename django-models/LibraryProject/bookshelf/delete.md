# Delete Operation

## Objective
Delete the book that was created and confirm the deletion by trying to retrieve all books again.

## Django Shell Commands

```python
# Import the Book model
from bookshelf.models import Book

# Retrieve the book to delete
book = Book.objects.get(title="Nineteen Eighty-Four")

# Display book details before deletion
print(f"Book to delete: {book.title} by {book.author} ({book.publication_year})")
print(f"Book ID: {book.id}")

# Delete the book
book.delete()
print("Book deleted successfully")

# Confirm deletion by checking all books
all_books = Book.objects.all()
print(f"Total books after deletion: {all_books.count()}")

# Try to retrieve the deleted book (this will raise an exception)
try:
    deleted_book = Book.objects.get(title="Nineteen Eighty-Four")
    print("Book still exists!")
except Book.DoesNotExist:
    print("Book has been successfully deleted - DoesNotExist exception raised")

# Display all remaining books
if all_books.exists():
    for book in all_books:
        print(f"Remaining book: {book}")
else:
    print("No books remaining in database")
```

## Expected Output
```
Book to delete: Nineteen Eighty-Four by George Orwell (1949)
Book ID: 1
Book deleted successfully
Total books after deletion: 0
Book has been successfully deleted - DoesNotExist exception raised
No books remaining in database
```

## Alternative Delete Methods
```python
# Delete by filtering
Book.objects.filter(title="Nineteen Eighty-Four").delete()

# Delete all books (use with caution)
Book.objects.all().delete()

# Bulk delete with conditions
Book.objects.filter(publication_year__lt=1950).delete()
```

## Notes
- `delete()` permanently removes the object from the database
- After deletion, the object can no longer be retrieved
- Django raises `DoesNotExist` exception when trying to get a non-existent object
- The `delete()` method returns a tuple with the number of deleted objects
