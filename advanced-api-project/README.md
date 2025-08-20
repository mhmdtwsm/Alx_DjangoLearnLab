# Advanced API Project - Django REST Framework

This project demonstrates advanced Django REST Framework concepts including custom serializers, nested relationships, and data validation.

## Project Structure

```
advanced-api-project/
├── venv/                          # Virtual environment
├── advanced_api_project/          # Django project directory
│   ├── __init__.py
│   ├── settings.py               # Project settings
│   ├── urls.py                   # URL configuration
│   ├── wsgi.py                   # WSGI configuration
│   └── asgi.py                   # ASGI configuration
├── api/                          # Django app
│   ├── __init__.py
│   ├── models.py                 # Author and Book models
│   ├── serializers.py            # Custom serializers
│   ├── admin.py                  # Admin configuration
│   ├── test_models.py            # Test script
│   └── views.py                  # API views (to be implemented)
├── manage.py                     # Django management script
├── requirements.txt              # Python dependencies
└── README.md                     # This file
```

## Models

### Author
- `name`: CharField - The author's full name
- Relationship: One-to-many with Books

### Book
- `title`: CharField - The book's title
- `publication_year`: IntegerField - Year of publication (validated)
- `author`: ForeignKey - Reference to Author model

## Serializers

### BookSerializer
- Serializes all Book fields
- Custom validation for `publication_year` (prevents future dates)
- Object-level validation for data integrity

### AuthorSerializer
- Includes nested BookSerializer for related books
- Shows author information with all their books
- Computed fields: `book_count`, `latest_publication_year`

## Setup and Usage

### 1. Activate Virtual Environment
```bash
source venv/bin/activate
```

### 2. Run Development Server
```bash
python manage.py runserver
```

### 3. Access Admin Interface
- URL: http://127.0.0.1:8000/admin/
- Create a superuser if you haven't: `python manage.py createsuperuser`

### 4. Test Models and Serializers
```bash
python manage.py shell
exec(open('api/test_models.py').read())
```

### 5. Django Shell Commands
```python
# Create test data
from api.models import Author, Book
from api.serializers import AuthorSerializer, BookSerializer

# Create an author
author = Author.objects.create(name="George Orwell")

# Create books
book1 = Book.objects.create(title="1984", publication_year=1949, author=author)
book2 = Book.objects.create(title="Animal Farm", publication_year=1945, author=author)

# Test serializers
author_serializer = AuthorSerializer(author)
print(author_serializer.data)
```

## Key Features Demonstrated

1. **Custom Model Relationships**: One-to-many relationship between Author and Book
2. **Advanced Serializers**: Nested serialization with BookSerializer inside AuthorSerializer
3. **Custom Validation**: Publication year validation in BookSerializer
4. **Dynamic Fields**: Computed fields like book count and latest publication year
5. **Admin Integration**: Customized Django admin for easy data management
6. **Data Integrity**: Unique constraints and proper validation

## Next Steps

- Implement API views and URL routing
- Add authentication and permissions
- Create API endpoints for CRUD operations
- Add pagination and filtering
- Implement API documentation with Django REST Framework's browsable API

## Dependencies

- Django
- Django REST Framework

See `requirements.txt` for specific versions.

## Generic Views Implementation

This project now includes comprehensive CRUD operations using Django REST Framework's generic views.

### New Features Added:
- ✅ Generic views for all CRUD operations
- ✅ Token authentication system
- ✅ Proper permission controls
- ✅ Custom response formats
- ✅ Query parameter filtering
- ✅ Comprehensive error handling
- ✅ Test data management command
- ✅ Automated API testing script

### API Endpoints:
- `GET /api/books/` - List all books (public)
- `GET /api/books/<id>/` - Get book details (public)
- `POST /api/books/create/` - Create new book (auth required)
- `PUT/PATCH /api/books/<id>/update/` - Update book (auth required)
- `DELETE /api/books/<id>/delete/` - Delete book (auth required)

### Authentication:
- `POST /api-token-auth/` - Get authentication token
- `GET /api-auth/` - Browsable API login/logout

### Quick Start:
1. Activate virtual environment: `source venv/bin/activate`
2. Create test data: `python manage.py create_test_data`
3. Start server: `python manage.py runserver`
4. Test API: `python test_api.py`

### Documentation:
See `API_DOCUMENTATION.md` for complete API documentation with examples.

## Generic Views Implementation

This project now includes comprehensive CRUD operations using Django REST Framework's generic views.

### New Features Added:
- ✅ Generic views for all CRUD operations
- ✅ Token authentication system
- ✅ Proper permission controls
- ✅ Custom response formats
- ✅ Query parameter filtering
- ✅ Comprehensive error handling
- ✅ Test data management command
- ✅ Automated API testing script

### API Endpoints:
- `GET /api/books/` - List all books (public)
- `GET /api/books/<id>/` - Get book details (public)
- `POST /api/books/create/` - Create new book (auth required)
- `PUT/PATCH /api/books/<id>/update/` - Update book (auth required)
- `DELETE /api/books/<id>/delete/` - Delete book (auth required)

### Authentication:
- `POST /api-token-auth/` - Get authentication token
- `GET /api-auth/` - Browsable API login/logout

### Quick Start:
1. Activate virtual environment: `source venv/bin/activate`
2. Create test data: `python manage.py create_test_data`
3. Start server: `python manage.py runserver`
4. Test API: `python test_api.py`

### Documentation:
See `API_DOCUMENTATION.md` for complete API documentation with examples.
