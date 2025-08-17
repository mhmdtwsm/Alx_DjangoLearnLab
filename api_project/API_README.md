# Django REST Framework API - Book Management

This API provides endpoints for managing book data using Django REST Framework.

## Quick Start

1. **Apply migrations** (if you haven't already):
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

2. **Create sample data** (optional):
   ```bash
   python create_sample_books.py
   ```

3. **Start the development server**:
   ```bash
   python manage.py runserver
   ```

4. **Test the API endpoints**:
   ```bash
   ./test_api.sh
   ```

## API Endpoints

### 1. API Overview
- **URL**: `/api/`
- **Method**: GET
- **Description**: Returns an overview of available API endpoints
- **Example**: `curl http://127.0.0.1:8000/api/`

### 2. List All Books
- **URL**: `/api/books/`
- **Method**: GET
- **Description**: Returns a JSON list of all books
- **Example**: `curl http://127.0.0.1:8000/api/books/`

**Sample Response**:
```json
[
  {
    "id": 1,
    "title": "The Django Book",
    "author": "Adrian Holovaty",
    "publication_year": 2009
  },
  {
    "id": 2,
    "title": "Two Scoops of Django", 
    "author": "Daniel Roy Greenfeld",
    "publication_year": 2020
  }
]
```

## Testing Methods

### Using curl
```bash
# Basic request
curl http://127.0.0.1:8000/api/books/

# With pretty JSON formatting
curl -s http://127.0.0.1:8000/api/books/ | python -m json.tool

# With headers
curl -H "Content-Type: application/json" http://127.0.0.1:8000/api/books/
```

### Using Browser
Simply navigate to `http://127.0.0.1:8000/api/books/` in your web browser.

### Using Python requests
```python
import requests
response = requests.get('http://127.0.0.1:8000/api/books/')
print(response.json())
```

## Project Structure

```
api_project/
├── api/
│   ├── __init__.py
│   ├── models.py          # Book model definition
│   ├── serializers.py     # BookSerializer (NEW)
│   ├── views.py          # BookList view (UPDATED)
│   ├── urls.py           # API URL patterns (NEW)
│   └── admin.py
├── api_project/
│   ├── settings.py       # Updated with rest_framework
│   ├── urls.py          # Updated to include api.urls
│   └── ...
├── manage.py
├── test_api.sh          # Testing script
├── create_sample_books.py # Sample data script
└── API_README.md        # This file
```

## Troubleshooting

### Common Issues

1. **ImportError: No module named 'rest_framework'**
   - Solution: Install Django REST Framework
   ```bash
   pip install djangorestframework
   ```

2. **404 Error when accessing /api/books/**
   - Check that `api.urls` is included in main `urls.py`
   - Verify the URL patterns are correct

3. **Empty response or no books**
   - Create sample data using `python create_sample_books.py`
   - Check that your Book model has data in Django admin

4. **Server not starting**
   - Apply migrations: `python manage.py migrate`
   - Check for syntax errors in your code

## Next Steps

- Add POST, PUT, DELETE endpoints for full CRUD operations
- Implement authentication and permissions  
- Add filtering, searching, and pagination
- Write unit tests for your API endpoints
- Add API documentation with tools like Swagger/OpenAPI
