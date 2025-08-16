# Create Operation

## Objective
Create a `Book` instance with the title "1984", author "George Orwell", and publication year 1949.

## Django Shell Commands

```python
# Import the Book model
from bookshelf.models import Book

# Create a new Book instance
book = Book(title="1984", author="George Orwell", publication_year=1949)

# Save the book to the database
book.save()

# Verify the book was created
print(f"Book created: {book.title} by {book.author} ({book.publication_year})")
print(f"Book ID: {book.id}")
```

## Expected Output
```
Book created: 1984 by George Orwell (1949)
Book ID: 1
```

## Alternative Method
```python
# Create and save in one step using create() method
book = Book.objects.create(title="1984", author="George Orwell", publication_year=1949)
print(f"Book created: {book}")
```

## Notes
- The `save()` method commits the object to the database
- After saving, Django automatically assigns an `id` (primary key) to the object
- The `__str__` method returns the book's title for string representation
