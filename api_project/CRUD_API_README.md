# Django REST Framework CRUD API - Complete Guide

This API provides full CRUD (Create, Read, Update, Delete) operations for managing books using Django REST Framework's ViewSets and Routers.

## Quick Start

1. **Apply migrations** (if you haven't already):
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

2. **Create sample data**:
   ```bash
   python create_sample_books_crud.py
   ```

3. **Start the development server**:
   ```bash
   python manage.py runserver
   ```

4. **Test the CRUD API endpoints**:
   ```bash
   ./test_crud_api.sh --run
   ```

## API Endpoints Overview

### Original ListAPIView Endpoint
- **URL**: `/api/books/`
- **Method**: GET
- **Description**: Returns a simple list of all books (original implementation)

### ViewSet CRUD Endpoints (books_all)

The ViewSet provides full CRUD operations at `/api/books_all/`:

| Operation | HTTP Method | URL | Description |
|-----------|-------------|-----|-------------|
| **List** | GET | `/api/books_all/` | Get all books |
| **Create** | POST | `/api/books_all/` | Create a new book |
| **Retrieve** | GET | `/api/books_all/{id}/` | Get a specific book |
| **Update** | PUT | `/api/books_all/{id}/` | Update a book (full) |
| **Partial Update** | PATCH | `/api/books_all/{id}/` | Update a book (partial) |
| **Delete** | DELETE | `/api/books_all/{id}/` | Delete a book |

## Detailed API Documentation

### 1. List All Books
- **URL**: `GET /api/books_all/`
- **Description**: Retrieve all books in the database
- **Response Format**:
```json
{
  "count": 5,
  "results": [
    {
      "id": 1,
      "title": "The Django Book",
      "author": "Adrian Holovaty",
      "publication_year": 2009
    }
  ]
}
```

**Example**:
```bash
curl -X GET http://127.0.0.1:8000/api/books_all/
```

### 2. Create a New Book
- **URL**: `POST /api/books_all/`
- **Description**: Create a new book
- **Request Body**:
```json
{
  "title": "New Book Title",
  "author": "Author Name",
  "publication_year": 2024
}
```
- **Response Format**:
```json
{
  "message": "Book created successfully",
  "data": {
    "id": 6,
    "title": "New Book Title",
    "author": "Author Name",
    "publication_year": 2024
  }
}
```

**Example**:
```bash
curl -X POST http://127.0.0.1:8000/api/books_all/ \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Book", "author": "Test Author", "publication_year": 2024}'
```

### 3. Retrieve a Specific Book
- **URL**: `GET /api/books_all/{id}/`
- **Description**: Get details of a specific book by ID
- **Response Format**:
```json
{
  "id": 1,
  "title": "The Django Book",
  "author": "Adrian Holovaty",
  "publication_year": 2009
}
```

**Example**:
```bash
curl -X GET http://127.0.0.1:8000/api/books_all/1/
```

### 4. Update a Book (Full Update)
- **URL**: `PUT /api/books_all/{id}/`
- **Description**: Update all fields of a specific book
- **Request Body**: All fields required
```json
{
  "title": "Updated Book Title",
  "author": "Updated Author",
  "publication_year": 2024
}
```
- **Response Format**:
```json
{
  "message": "Book updated successfully",
  "data": {
    "id": 1,
    "title": "Updated Book Title",
    "author": "Updated Author",
    "publication_year": 2024
  }
}
```

**Example**:
```bash
curl -X PUT http://127.0.0.1:8000/api/books_all/1/ \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated Title", "author": "Updated Author", "publication_year": 2024}'
```

### 5. Partial Update a Book
- **URL**: `PATCH /api/books_all/{id}/`
- **Description**: Update specific fields of a book
- **Request Body**: Only fields to update
```json
{
  "title": "New Title Only"
}
```
- **Response Format**:
```json
{
  "message": "Book partially updated successfully",
  "data": {
    "id": 1,
    "title": "New Title Only",
    "author": "Original Author",
    "publication_year": 2009
  }
}
```

**Example**:
```bash
curl -X PATCH http://127.0.0.1:8000/api/books_all/1/ \
  -H "Content-Type: application/json" \
  -d '{"title": "Partially Updated Title"}'
```

### 6. Delete a Book
- **URL**: `DELETE /api/books_all/{id}/`
- **Description**: Delete a specific book
- **Response Format**:
```json
{
  "message": "Book \"Book Title\" deleted successfully"
}
```

**Example**:
```bash
curl -X DELETE http://127.0.0.1:8000/api/books_all/1/
```

## Error Handling

The API provides comprehensive error handling:

### Common Error Responses

**404 Not Found**:
```json
{
  "error": "Book not found"
}
```

**400 Bad Request** (Validation Error):
```json
{
  "error": "Validation failed",
  "details": {
    "title": ["This field is required."],
    "publication_year": ["Publication year cannot be in the future."]
  }
}
```

**500 Internal Server Error**:
```json
{
  "error": "Failed to create book",
  "details": "Specific error message"
}
```

## Testing Methods

### Using curl (Command Line)
```bash
# List all books
curl -X GET http://127.0.0.1:8000/api/books_all/

# Create a book
curl -X POST http://127.0.0.1:8000/api/books_all/ \
  -H "Content-Type: application/json" \
  -d '{"title": "Test", "author": "Author", "publication_year": 2024}'

# Get specific book
curl -X GET http://127.0.0.1:8000/api/books_all/1/

# Update book
curl -X PUT http://127.0.0.1:8000/api/books_all/1/ \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated", "author": "Updated Author", "publication_year": 2024}'

# Partial update
curl -X PATCH http://127.0.0.1:8000/api/books_all/1/ \
  -H "Content-Type: application/json" \
  -d '{"title": "New Title"}'

# Delete book
curl -X DELETE http://127.0.0.1:8000/api/books_all/1/
```

### Using Python requests
```python
import requests
import json

base_url = "http://127.0.0.1:8000/api/books_all/"

# List all books
response = requests.get(base_url)
print(response.json())

# Create a book
new_book = {
    "title": "Python API Book",
    "author": "API Author",
    "publication_year": 2024
}
response = requests.post(base_url, json=new_book)
print(response.json())

# Get specific book (assuming ID 1)
response = requests.get(f"{base_url}1/")
print(response.json())

# Update book
updated_book = {
    "title": "Updated Python Book",
    "author": "Updated Author",
    "publication_year": 2024
}
response = requests.put(f"{base_url}1/", json=updated_book)
print(response.json())

# Partial update
partial_update = {"title": "Partially Updated Title"}
response = requests.patch(f"{base_url}1/", json=partial_update)
print(response.json())

# Delete book
response = requests.delete(f"{base_url}1/")
print(response.status_code)  # Should be 204
```

### Using Browser (for GET requests)
- List all books: `http://127.0.0.1:8000/api/books_all/`
- Get specific book: `http://127.0.0.1:8000/api/books_all/1/`
- API overview: `http://127.0.0.1:8000/api/`

## Project Structure

```
api_project/
├── api/
│   ├── __init__.py
│   ├── models.py              # Book model definition
│   ├── serializers.py         # BookSerializer
│   ├── views.py              # BookList + BookViewSet (UPDATED)
│   ├── urls.py               # Router configuration (UPDATED)
│   └── admin.py
├── api_project/
│   ├── settings.py           # Updated with rest_framework
│   ├── urls.py              # Updated to include api.urls
│   └── ...
├── manage.py
├── test_crud_api.sh         # CRUD testing script
├── create_sample_books_crud.py # Enhanced sample data
└── CRUD_API_README.md       # This documentation
```

## Troubleshooting

### Common Issues

1. **404 Error on ViewSet endpoints**
   - Ensure the router is properly configured in `urls.py`
   - Check that `DefaultRouter` is imported and registered correctly

2. **405 Method Not Allowed**
   - Verify you're using the correct HTTP method for the operation
   - Check that the ViewSet supports the method you're trying to use

3. **400 Bad Request on POST/PUT**
   - Verify your JSON data format matches the serializer requirements
   - Check that all required fields are included
   - Ensure `Content-Type: application/json` header is set

4. **500 Internal Server Error**
   - Check Django server logs for detailed error information
   - Verify database migrations are applied
   - Ensure all required dependencies are installed

### Validation Rules

The API enforces these validation rules:
- **Title**: Cannot be empty or whitespace only
- **Publication Year**: Cannot be in the future
- **All fields**: Required for full updates (PUT)

## Next Steps

- Add authentication and permissions
- Implement filtering, searching, and pagination
- Add more complex validation rules
- Write comprehensive unit tests
- Add API documentation with Swagger/OpenAPI
- Implement rate limiting
- Add caching for better performance
