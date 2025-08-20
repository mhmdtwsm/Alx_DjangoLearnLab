# Django REST Framework Filtering, Searching, and Ordering API Documentation

## Overview

This API provides advanced filtering, searching, and ordering capabilities for the Book model. Users can combine multiple query parameters to find exactly the books they need.

## Base URL

```
http://127.0.0.1:8000/api/books/
```

## Supported Features

### 1. Filtering
Filter books by specific attributes:

#### Title Filtering
- `title` - Exact title match (case-insensitive)
- `title_contains` - Partial title match (case-insensitive)

**Examples:**
```bash
GET /api/books/?title=Django%20for%20Beginners
GET /api/books/?title_contains=Django
```

#### Author Filtering
- `author` - Filter by author ID
- `author_name` - Filter by author name (case-insensitive partial match)

**Examples:**
```bash
GET /api/books/?author=1
GET /api/books/?author_name=John
```

#### Publication Year Filtering
- `publication_year` - Exact year match
- `publication_year_gte` - Books published in or after this year
- `publication_year_lte` - Books published in or before this year
- `publication_year_range` - Range filtering (format: min_value,max_value)

**Examples:**
```bash
GET /api/books/?publication_year=2023
GET /api/books/?publication_year_gte=2020
GET /api/books/?publication_year_lte=2023
GET /api/books/?publication_year_range=2020,2023
```

### 2. Searching
Global search across multiple fields:

- `search` - Search in title and author name fields

**Examples:**
```bash
GET /api/books/?search=Django
GET /api/books/?search=Python%20programming
```

### 3. Ordering
Sort results by any field:

- `ordering` - Order by field name (prefix with `-` for descending)

**Available ordering fields:**
- `title` - Book title
- `publication_year` - Publication year
- `author__name` - Author name

**Examples:**
```bash
GET /api/books/?ordering=title
GET /api/books/?ordering=-publication_year
GET /api/books/?ordering=author__name
```

### 4. Combining Parameters
You can combine multiple query parameters:

**Examples:**
```bash
# Search for Django books, ordered by publication year
GET /api/books/?search=Django&ordering=-publication_year

# Filter by author and year range, then order by title
GET /api/books/?author_name=John&publication_year_gte=2020&ordering=title

# Complex filtering with search and multiple filters
GET /api/books/?search=Python&author_name=Smith&publication_year_lte=2023&ordering=-title
```

## Response Format

All responses follow this format:

```json
{
    "message": "Books retrieved successfully",
    "count": 10,
    "data": [
        {
            "id": 1,
            "title": "Django for Beginners",
            "author": 1,
            "author_name": "John Doe",
            "publication_year": 2023
        }
    ],
    "filters_applied": {
        "search": "Django",
        "ordering": "title",
        "filters": {
            "author_name": "John"
        }
    }
}
```

## Error Handling

### Invalid Parameters
If invalid query parameters are provided, the API will ignore them and return available results.

### No Results Found
If no books match the criteria:

```json
{
    "message": "Books retrieved successfully",
    "count": 0,
    "data": [],
    "filters_applied": {
        "search": "NonexistentBook",
        "ordering": "title",
        "filters": {}
    }
}
```

## Pagination

The API supports pagination with the following parameters:
- `page` - Page number (default: 1)
- `page_size` - Items per page (default: 10, max: 100)

**Example:**
```bash
GET /api/books/?page=2&search=Django&ordering=title
```

**Paginated Response:**
```json
{
    "count": 25,
    "next": "http://127.0.0.1:8000/api/books/?page=3&search=Django",
    "previous": "http://127.0.0.1:8000/api/books/?page=1&search=Django",
    "results": [...]
}
```

## Complete Examples

### 1. Basic Listing
```bash
curl "http://127.0.0.1:8000/api/books/"
```

### 2. Search for Books
```bash
curl "http://127.0.0.1:8000/api/books/?search=Python"
```

### 3. Filter by Author
```bash
curl "http://127.0.0.1:8000/api/books/?author_name=Smith"
```

### 4. Filter by Publication Year Range
```bash
curl "http://127.0.0.1:8000/api/books/?publication_year_gte=2020&publication_year_lte=2023"
```

### 5. Complex Query
```bash
curl "http://127.0.0.1:8000/api/books/?search=Django&author_name=John&publication_year_gte=2020&ordering=-publication_year"
```

### 6. Order by Title (Descending)
```bash
curl "http://127.0.0.1:8000/api/books/?ordering=-title"
```

## Testing the API

Use the provided test script to verify functionality:

```bash
# Run the comprehensive test suite
./test_filtering_advanced.py

# Or test individual endpoints manually
python manage.py test api.tests
```

## Author API

The Author endpoints also support filtering and searching:

### Author List: `/api/authors/`
- `search` - Search by author name
- `ordering` - Order by name

**Examples:**
```bash
GET /api/authors/?search=John
GET /api/authors/?ordering=-name
```

## Implementation Details

### Filter Backend Configuration
The API uses Django REST Framework's filter backends:

- `DjangoFilterBackend` - For field-based filtering
- `SearchFilter` - For text search across multiple fields
- `OrderingFilter` - For result sorting

### Custom Filter Class
A custom `BookFilter` class provides advanced filtering options using `django-filter` package.

### Performance Considerations
- Filtering is performed at the database level for optimal performance
- Indexes should be added to frequently filtered fields in production
- Consider pagination for large datasets

## Security Notes

- All filtering operations are read-only and safe
- No user authentication required for filtering (read-only operations)
- Write operations (POST, PUT, DELETE) require authentication
- Input validation prevents SQL injection attacks

## Troubleshooting

### Common Issues

1. **Empty Results**: Check if filter parameters are correctly formatted
2. **Invalid Ordering**: Ensure ordering field names are valid
3. **Server Errors**: Check Django logs for detailed error information

### Debug Tips

1. Use the `filters_applied` field in responses to verify what filters were actually applied
2. Test individual filters before combining them
3. Check the Django admin panel to verify your test data exists

## API Versioning

This documentation covers API version 1.0. Future versions may introduce additional filtering capabilities while maintaining backward compatibility.
