# Update Operation

## Objective
Update the title of "1984" to "Nineteen Eighty-Four" and save the changes.

## Django Shell Commands

```python
# Import the Book model
from bookshelf.models import Book

# Retrieve the book to update
book = Book.objects.get(title="1984")

# Display current title
print(f"Current title: {book.title}")

# Update the title
book.title = "Nineteen Eighty-Four"

# Save the changes to the database
book.save()

# Verify the update
print(f"Updated title: {book.title}")

# Retrieve the book again to confirm the change persisted
updated_book = Book.objects.get(id=book.id)
print(f"Title from database: {updated_book.title}")
```

## Expected Output
```
Current title: 1984
Updated title: Nineteen Eighty-Four
Title from database: Nineteen Eighty-Four
```

## Alternative Update Methods
```python
# Update using update() method (affects database directly)
Book.objects.filter(title="1984").update(title="Nineteen Eighty-Four")

# Bulk update multiple fields
book = Book.objects.get(title="Nineteen Eighty-Four")
book.title = "Nineteen Eighty-Four"
book.author = "George Orwell (Updated)"
book.save()
```

## Notes
- Always call `save()` after modifying object attributes to persist changes
- The `update()` method directly updates the database without loading objects into memory
- After updating, the object in memory reflects the changes
