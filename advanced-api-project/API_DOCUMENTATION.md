# Django REST Framework Generic Views API Documentation

## Overview
This API provides full CRUD operations for Book management using Django REST Framework's generic views with proper authentication and permissions.

## Authentication
- **Token Authentication**: Required for write operations (CREATE, UPDATE, DELETE)
- **Session Authentication**: Available for web browsing
- **Anonymous Access**: Allowed for read operations (LIST, RETRIEVE)

## Base URL
```
http://127.0.0.1:8000/api/
```

## Authentication Endpoints

### Get Authentication Token
```http
POST /api-token-auth/
```
**Body:**
```json
{
    "username": "your_username",
    "password": "your_password"
}
```
**Response:**
```json
{
    "token": "your_authentication_token"
}
```

## Book Endpoints

### 1. List All Books
```http
GET /api/books/
```
- **Permission**: Public (no authentication required)
- **Description**: Retrieve all books with optional filtering
- **Query Parameters**:
  - `title`: Filter by title (case-insensitive contains)
  - `author`: Filter by author (case-insensitive contains)

**Example:**
```bash
curl -X GET "http://127.0.0.1:8000/api/books/?title=django"
```

**Response:**
```json
[
    {
        "id": 1,
        "title": "Django for Beginners",
        "author": "William Vincent"
    },
    {
        "id": 2,
        "title": "Two Scoops of Django",
        "author": "Daniel Roy Greenfeld"
    }
]
```

### 2. Get Book Details
```http
GET /api/books/{id}/
```
- **Permission**: Public (no authentication required)
- **Description**: Retrieve a specific book by ID

**Example:**
```bash
curl -X GET "http://127.0.0.1:8000/api/books/1/"
```

**Response:**
```json
{
    "id": 1,
    "title": "Django for Beginners",
    "author": "William Vincent"
}
```

### 3. Create New Book
```http
POST /api/books/create/
```
- **Permission**: Authenticated users only
- **Description**: Create a new book

**Headers:**
```
Authorization: Token your_token_here
Content-Type: application/json
```

**Body:**
```json
{
    "title": "New Book Title",
    "author": "Author Name"
}
```

**Example:**
```bash
curl -X POST "http://127.0.0.1:8000/api/books/create/" \
     -H "Authorization: Token your_token_here" \
     -H "Content-Type: application/json" \
     -d '{"title": "New Book", "author": "New Author"}'
```

**Response:**
```json
{
    "message": "Book created successfully",
    "data": {
        "id": 3,
        "title": "New Book Title",
        "author": "Author Name"
    }
}
```

### 4. Update Book
```http
PUT /api/books/{id}/update/
PATCH /api/books/{id}/update/
```
- **Permission**: Authenticated users only
- **Description**: Update an existing book (PUT for full update, PATCH for partial)

**Headers:**
```
Authorization: Token your_token_here
Content-Type: application/json
```

**Body (PUT - all fields required):**
```json
{
    "title": "Updated Book Title",
    "author": "Updated Author Name"
}
```

**Body (PATCH - partial update):**
```json
{
    "title": "Just Update Title"
}
```

**Example:**
```bash
curl -X PATCH "http://127.0.0.1:8000/api/books/1/update/" \
     -H "Authorization: Token your_token_here" \
     -H "Content-Type: application/json" \
     -d '{"title": "Updated Title"}'
```

**Response:**
```json
{
    "message": "Book updated successfully",
    "data": {
        "id": 1,
        "title": "Updated Title",
        "author": "Original Author"
    }
}
```

### 5. Delete Book
```http
DELETE /api/books/{id}/delete/
```
- **Permission**: Authenticated users only
- **Description**: Delete a specific book

**Headers:**
```
Authorization: Token your_token_here
```

**Example:**
```bash
curl -X DELETE "http://127.0.0.1:8000/api/books/1/delete/" \
     -H "Authorization: Token your_token_here"
```

**Response:**
```json
{
    "message": "Book \"Book Title\" deleted successfully"
}
```

## Error Responses

### 401 Unauthorized
```json
{
    "detail": "Authentication credentials were not provided."
}
```

### 403 Forbidden
```json
{
    "detail": "You do not have permission to perform this action."
}
```

### 404 Not Found
```json
{
    "detail": "Not found."
}
```

### 400 Bad Request
```json
{
    "message": "Failed to create book",
    "errors": {
        "title": ["This field is required."]
    }
}
```

## Testing the API

### 1. Setup Test Data
```bash
python manage.py create_test_data
```

### 2. Run Automated Tests
```bash
python test_api.py
```

### 3. Manual Testing with curl

**Get all books:**
```bash
curl -X GET "http://127.0.0.1:8000/api/books/"
```

**Get authentication token:**
```bash
curl -X POST "http://127.0.0.1:8000/api-token-auth/" \
     -d "username=testuser&password=testpass123"
```

**Create a book:**
```bash
curl -X POST "http://127.0.0.1:8000/api/books/create/" \
     -H "Authorization: Token YOUR_TOKEN_HERE" \
     -H "Content-Type: application/json" \
     -d '{"title": "Test Book", "author": "Test Author"}'
```

## Implementation Details

### Generic Views Used
- **BookListView**: `generics.ListAPIView` for listing books
- **BookDetailView**: `generics.RetrieveAPIView` for book details
- **BookCreateView**: `generics.CreateAPIView` for creating books
- **BookUpdateView**: `generics.UpdateAPIView` for updating books
- **BookDeleteView**: `generics.DestroyAPIView` for deleting books

### Permissions
- **IsAuthenticatedOrReadOnly**: Allows read access to everyone, write access only to authenticated users
- **IsAuthenticated**: Requires authentication for all operations

### Custom Features
- Custom response formats with success/error messages
- Query parameter filtering for book list
- Proper error handling with meaningful messages
- Token authentication support
- Browsable API interface available at endpoints
