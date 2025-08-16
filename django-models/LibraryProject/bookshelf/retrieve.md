# Retrieve Operation

## Objective
Retrieve and display all attributes of the book that was just created.

## Django Shell Commands

```python
# Import the Book model
from bookshelf.models import Book

# Retrieve the book by title
book = Book.objects.get(title="1984")

# Display all attributes
print(f"ID: {book.id}")
print(f"Title: {book.title}")
print(f"Author: {book.author}")
print(f"Publication Year: {book.publication_year}")

# Alternative: Get all books and display them
all_books = Book.objects.all()
for book in all_books:
    print(f"Book: {book.title} by {book.author} ({book.publication_year})")
```

## Expected Output
```
ID: 1
Title: 1984
Author: George Orwell
Publication Year: 1949
Book: 1984 by George Orwell (1949)
```

## Additional Retrieval Methods
```python
# Get all books
all_books = Book.objects.all()
print(f"Total books: {all_books.count()}")

# Get book by ID
book = Book.objects.get(id=1)
print(book)

# Filter books by author
orwell_books = Book.objects.filter(author="George Orwell")
print(f"Books by George Orwell: {orwell_books.count()}")
```

## Notes
- `get()` returns a single object or raises an exception if not found
- `all()` returns a QuerySet containing all objects
- `filter()` returns a QuerySet of objects matching the criteria
