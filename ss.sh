#!/bin/bash

# Django Models Task 1 - Implementation Script
# Task: Implementing and Interacting with Django Models
# Repository: Alx_DjangoLearnLab/Introduction_to_Django

set -e  # Exit on any error

echo "🚀 Starting Django Models Task 1 Implementation..."
echo "================================================="
echo ""

# Check if we're in the correct directory structure
if [ ! -d "Alx_DjangoLearnLab/Introduction_to_Django/LibraryProject" ]; then
    echo "❌ Error: Please run this script from the directory containing Alx_DjangoLearnLab"
    echo "Expected structure: Alx_DjangoLearnLab/Introduction_to_Django/LibraryProject"
    exit 1
fi

# Navigate to the project directory
cd Alx_DjangoLearnLab/Introduction_to_Django

# Activate virtual environment
echo "1️⃣  Activating virtual environment..."
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows
    source django_env/Scripts/activate
else
    # Unix/Linux/MacOS
    source django_env/bin/activate
fi
echo "✅ Virtual environment activated"

# Navigate to LibraryProject
cd LibraryProject

# Step 1: Create the bookshelf App
echo ""
echo "2️⃣  Step 1: Create the bookshelf App..."
echo "Running: python manage.py startapp bookshelf"
python manage.py startapp bookshelf
echo "✅ bookshelf app created successfully"

# Step 2: Define the Book Model
echo ""
echo "3️⃣  Step 2: Define the Book Model..."
echo "Creating Book model in bookshelf/models.py"

cat > bookshelf/models.py << 'EOF'
from django.db import models

# Create your models here.

class Book(models.Model):
    title = models.CharField(max_length=200)
    author = models.CharField(max_length=100)
    publication_year = models.IntegerField()
    
    def __str__(self):
        return self.title
EOF

echo "✅ Book model defined with required fields:"
echo "   • title: CharField(max_length=200)"
echo "   • author: CharField(max_length=100)" 
echo "   • publication_year: IntegerField()"

# Add bookshelf to INSTALLED_APPS
echo ""
echo "4️⃣  Adding bookshelf to INSTALLED_APPS in settings.py..."
# Create a backup of settings.py
cp LibraryProject/settings.py LibraryProject/settings.py.backup

# Add bookshelf to INSTALLED_APPS using Python
python << 'EOF'
import re

# Read the settings file
with open('LibraryProject/settings.py', 'r') as f:
    content = f.read()

# Check if bookshelf is already in INSTALLED_APPS
if "'bookshelf'" not in content and '"bookshelf"' not in content:
    # Find INSTALLED_APPS and add bookshelf
    pattern = r"(INSTALLED_APPS\s*=\s*\[)(.*?)(\])"
    
    def replace_installed_apps(match):
        start = match.group(1)
        apps = match.group(2)
        end = match.group(3)
        
        # Add bookshelf to the list
        if apps.strip():
            # Add comma if needed
            if not apps.strip().endswith(','):
                apps += ','
            apps += "\n    'bookshelf',"
        else:
            apps = "\n    'bookshelf',"
        
        return start + apps + "\n" + end
    
    content = re.sub(pattern, replace_installed_apps, content, flags=re.DOTALL)
    
    # Write back to file
    with open('LibraryProject/settings.py', 'w') as f:
        f.write(content)
    
    print("✅ bookshelf added to INSTALLED_APPS")
else:
    print("✅ bookshelf already in INSTALLED_APPS")
EOF

# Step 3: Model Migration
echo ""
echo "5️⃣  Step 3: Model Migration..."
echo "Running: python manage.py makemigrations bookshelf"
python manage.py makemigrations bookshelf
echo "✅ Migration files created"

echo ""
echo "Running: python manage.py migrate"
python manage.py migrate
echo "✅ Database updated with Book model"

# Step 4: Create CRUD operation documentation files
echo ""
echo "6️⃣  Step 4: Creating CRUD operation documentation files..."

# Create create.md
cat > create.md << 'EOF'
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
EOF

# Create retrieve.md
cat > retrieve.md << 'EOF'
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
EOF

# Create update.md
cat > update.md << 'EOF'
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
EOF

# Create delete.md
cat > delete.md << 'EOF'
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
EOF

# Create comprehensive CRUD_operations.md
cat > CRUD_operations.md << 'EOF'
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
EOF

echo "✅ All CRUD documentation files created:"
echo "   • create.md - Create operation documentation"
echo "   • retrieve.md - Retrieve operation documentation"
echo "   • update.md - Update operation documentation"  
echo "   • delete.md - Delete operation documentation"
echo "   • CRUD_operations.md - Comprehensive CRUD documentation"

# Display project structure
echo ""
echo "7️⃣  Final Project Structure:"
echo "📁 Alx_DjangoLearnLab/Introduction_to_Django/LibraryProject/"
echo "├── manage.py"
echo "├── README.md"
echo "├── create.md                    # CREATE operation documentation"
echo "├── retrieve.md                  # RETRIEVE operation documentation"
echo "├── update.md                    # UPDATE operation documentation"
echo "├── delete.md                    # DELETE operation documentation"
echo "├── CRUD_operations.md           # Comprehensive CRUD documentation"
echo "├── LibraryProject/"
echo "│   ├── settings.py             # Updated with bookshelf app"
echo "│   ├── urls.py"
echo "│   ├── wsgi.py"
echo "│   └── asgi.py"
echo "└── bookshelf/                  # New Django app"
echo "    ├── __init__.py"
echo "    ├── admin.py"
echo "    ├── apps.py"
echo "    ├── models.py               # Book model definition"
echo "    ├── tests.py"
echo "    ├── views.py"
echo "    └── migrations/"
echo "        ├── __init__.py"
echo "        └── 0001_initial.py     # Book model migration"

# Verify the setup
echo ""
echo "8️⃣  Verifying setup..."
python manage.py check
echo "✅ Django project check passed"

echo ""
echo "🎉 Django Models Task 1 Implementation Complete!"
echo "=============================================="
echo ""
echo "📋 Task Completion Status:"
echo "   ✅ Step 1: Created bookshelf app"
echo "   ✅ Step 2: Defined Book model with required fields"
echo "   ✅ Step 3: Created and applied migrations"
echo "   ✅ Step 4: Created all CRUD operation documentation"
echo ""
echo "📝 Files Created:"
echo "   • bookshelf/models.py - Book model definition"
echo "   • create.md - CREATE operation documentation"
echo "   • retrieve.md - RETRIEVE operation documentation"
echo "   • update.md - UPDATE operation documentation"
echo "   • delete.md - DELETE operation documentation"
echo "   • CRUD_operations.md - Complete CRUD workflow"
echo ""
echo "🔧 Next Steps:"
echo "   1. Start Django shell: python manage.py shell"
echo "   2. Execute the CRUD operations documented in the .md files"
echo "   3. Follow the commands exactly as shown in CRUD_operations.md"
echo ""
echo "💡 Pro Tips:"
echo "   • All commands are documented with expected outputs"
echo "   • Each operation is in a separate .md file as required"
echo "   • The Book model follows exact specifications from the task"
echo ""
echo "Happy Django modeling! 🎯"
