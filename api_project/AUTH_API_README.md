# Django REST Framework Authentication & Permissions Guide

This guide covers the complete authentication and permission system implemented in your Django REST Framework API.

## Quick Start

1. **Apply migrations** (if you haven't already):
   ```bash
   python manage.py migrate
   ```

2. **Create test users**:
   ```bash
   python manage_users.py create
   ```

3. **Start the development server**:
   ```bash
   python manage.py runserver
   ```

4. **Test authentication**:
   ```bash
   ./test_auth_api.sh --run
   ```

## Authentication System Overview

### Authentication Methods
- **Token Authentication**: Primary method using DRF's token system
- **Session Authentication**: For browsable API interface

### Permission Classes
- **IsAuthenticated**: Requires valid authentication token
- **AllowAny**: Public endpoints (no authentication required)

## API Endpoints

### Authentication Endpoints

#### 1. User Registration
- **URL**: `POST /api/auth/register/`
- **Description**: Create a new user account
- **Authentication**: Not required (public)
- **Request Body**:
```json
{
  "username": "newuser",
  "password": "securepassword",
  "email": "user@example.com"
}
```
- **Response**:
```json
{
  "message": "User created successfully",
  "user_id": 1,
  "username": "newuser",
  "token": "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b"
}
```

**Example**:
```bash
curl -X POST http://127.0.0.1:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "testpass123", "email": "test@example.com"}'
```

#### 2. Get Authentication Token
- **URL**: `POST /api/auth/token/`
- **Description**: Obtain authentication token for existing user
- **Authentication**: Not required (public)
- **Request Body**:
```json
{
  "username": "existinguser",
  "password": "userpassword"
}
```
- **Response**:
```json
{
  "token": "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b",
  "user_id": 1,
  "username": "existinguser",
  "email": "user@example.com",
  "message": "Authentication successful"
}
```

**Example**:
```bash
curl -X POST http://127.0.0.1:8000/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "testpass123"}'
```

### Protected Endpoints (Require Authentication)

All book-related endpoints now require authentication. Include the token in the `Authorization` header:

```
Authorization: Token 9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b
```

#### Book Endpoints

| Endpoint | Method | Description | Authentication Required |
|----------|--------|-------------|------------------------|
| `/api/books/` | GET | List all books (ListAPIView) | ✅ Yes |
| `/api/books_all/` | GET | List all books (ViewSet) | ✅ Yes |
| `/api/books_all/` | POST | Create new book | ✅ Yes |
| `/api/books_all/{id}/` | GET | Get specific book | ✅ Yes |
| `/api/books_all/{id}/` | PUT | Update book (full) | ✅ Yes |
| `/api/books_all/{id}/` | PATCH | Update book (partial) | ✅ Yes |
| `/api/books_all/{id}/` | DELETE | Delete book | ✅ Yes |

### Public Endpoints (No Authentication Required)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/` | GET | API overview |
| `/api/books-public/` | GET | Public book list (for testing) |
| `/api/auth/register/` | POST | User registration |
| `/api/auth/token/` | POST | Get authentication token |

## Usage Examples

### 1. Complete Authentication Flow

```bash
# Step 1: Register a new user
curl -X POST http://127.0.0.1:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"username": "apiuser", "password": "securepass123", "email": "api@example.com"}'

# Response will include a token, or get token separately:
curl -X POST http://127.0.0.1:8000/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "apiuser", "password": "securepass123"}'

# Step 2: Use token to access protected endpoints
TOKEN="your_token_here"

# List books
curl -X GET http://127.0.0.1:8000/api/books_all/ \
  -H "Authorization: Token $TOKEN"

# Create a book
curl -X POST http://127.0.0.1:8000/api/books_all/ \
  -H "Authorization: Token $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "Authenticated Book", "author": "API User", "publication_year": 2024}'
```

### 2. Python requests Example

```python
import requests

base_url = "http://127.0.0.1:8000/api"

# Step 1: Register or get token
auth_data = {
    "username": "apiuser",
    "password": "securepass123"
}

# Get token
response = requests.post(f"{base_url}/auth/token/", json=auth_data)
token_data = response.json()
token = token_data['token']

# Step 2: Set up headers with token
headers = {
    'Authorization': f'Token {token}',
    'Content-Type': 'application/json'
}

# Step 3: Make authenticated requests
# List books
response = requests.get(f"{base_url}/books_all/", headers=headers)
books = response.json()
print(books)

# Create a book
new_book = {
    "title": "Python API Book",
    "author": "Python Developer",
    "publication_year": 2024
}
response = requests.post(f"{base_url}/books_all/", json=new_book, headers=headers)
created_book = response.json()
print(created_book)
```

### 3. JavaScript/Fetch Example

```javascript
const baseUrl = 'http://127.0.0.1:8000/api';

// Get authentication token
async function getToken(username, password) {
    const response = await fetch(`${baseUrl}/auth/token/`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ username, password })
    });
    
    const data = await response.json();
    return data.token;
}

// Make authenticated API calls
async function fetchBooks(token) {
    const response = await fetch(`${baseUrl}/books_all/`, {
        headers: {
            'Authorization': `Token ${token}`,
        }
    });
    
    return await response.json();
}

// Usage
(async () => {
    const token = await getToken('apiuser', 'securepass123');
    const books = await fetchBooks(token);
    console.log(books);
})();
```

## Error Handling

### Authentication Errors

**401 Unauthorized** - Invalid or missing token:
```json
{
    "detail": "Invalid token."
}
```

**401 Unauthorized** - No token provided:
```json
{
    "detail": "Authentication credentials were not provided."
}
```

**400 Bad Request** - Invalid login credentials:
```json
{
    "error": "Invalid credentials",
    "details": {
        "non_field_errors": ["Unable to log in with provided credentials."]
    }
}
```

### Permission Errors

**403 Forbidden** - Insufficient permissions:
```json
{
    "detail": "You do not have permission to perform this action."
}
```

## Security Best Practices

### Token Management
1. **Store tokens securely** - Never expose tokens in client-side code
2. **Use HTTPS in production** - Tokens should never be transmitted over HTTP
3. **Implement token rotation** - Consider implementing token refresh mechanisms
4. **Set token expiration** - Configure token expiration in production

### API Security
1. **Rate limiting** - Implement rate limiting to prevent abuse
2. **CORS configuration** - Configure CORS properly for web applications
3. **Input validation** - All input is validated through DRF serializers
4. **Error handling** - Sensitive information is not exposed in error messages

## Testing Authentication

### Using the Test Script
```bash
# Run all authentication tests
./test_auth_api.sh --run

# Create a test superuser
./test_auth_api.sh --create-superuser

# Show help
./test_auth_api.sh --help
```

### Manual Testing Checklist

1. ✅ **Public endpoints work without authentication**
   - GET /api/ (API overview)
   - GET /api/books-public/ (public book list)

2. ✅ **User registration works**
   - POST /api/auth/register/ creates user and returns token

3. ✅ **Token authentication works**
   - POST /api/auth/token/ returns token for valid credentials

4. ✅ **Protected endpoints reject unauthenticated requests**
   - GET /api/books/ returns 401 without token

5. ✅ **Protected endpoints accept authenticated requests**
   - GET /api/books/ returns data with valid token

6. ✅ **CRUD operations work with authentication**
   - All ViewSet operations require and accept valid tokens

## User Management

### Create Test Users
```bash
python manage_users.py create
```

### List All Users
```bash
python manage_users.py list
```

### Delete Test Users
```bash
python manage_users.py delete
```

## Configuration Details

### Settings Configuration
```python
# In api_project/settings.py
INSTALLED_APPS = [
    # ... other apps
    'rest_framework',
    'rest_framework.authtoken',  # Required for token authentication
    'api',
]

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',
    ],
}
```

### View-Level Permissions
```python
# Different permission classes can be applied per view
class BookViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]  # Requires authentication
    
class PublicBookView(generics.ListAPIView):
    permission_classes = [AllowAny]  # Public access
```

## Troubleshooting

### Common Issues

1. **Token not working**
   - Verify token format: `Authorization: Token your_token_here`
   - Check that `rest_framework.authtoken` is in INSTALLED_APPS
   - Ensure migrations have been run

2. **403 Forbidden errors**
   - Check that user has necessary permissions
   - Verify permission classes are correctly configured

3. **User registration fails**
   - Check that username is unique
   - Verify password meets any requirements
   - Ensure all required fields are provided

4. **Token not generated**
   - Run migrations: `python manage.py migrate`
   - Check that Token model is available

## Next Steps

- Implement token refresh mechanism
- Add role-based permissions
- Implement API rate limiting
- Add OAuth2 authentication
- Set up HTTPS for production
- Implement audit logging
- Add API versioning
