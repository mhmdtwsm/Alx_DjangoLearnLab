from django.urls import path
from . import views

# URL patterns for the API endpoints
urlpatterns = [
    # API Home
    path("", views.api_home, name="api_home"),
    # Book CRUD endpoints using separate generic views
    path("books/", views.BookListView.as_view(), name="book_list"),
    path("books/<int:pk>/", views.BookDetailView.as_view(), name="book_detail"),
    path("books/create/", views.BookCreateView.as_view(), name="book_create"),
    path("books/update/<int:pk>/", views.BookUpdateView.as_view(), name="book_update"),
    path("books/delete/<int:pk>/", views.BookDeleteView.as_view(), name="book_delete"),
]

# URL pattern names explanation:
# - book_list: GET /api/books/ - List all books (with optional filtering)
# - book_detail: GET /api/books/<id>/ - Retrieve a specific book
# - book_create: POST /api/books/create/ - Create a new book (auth required)
# - book_update: PUT/PATCH /api/books/update/<id>/ - Update a book (auth required)
# - book_delete: DELETE /api/books/delete/<id>/ - Delete a book (auth required)
