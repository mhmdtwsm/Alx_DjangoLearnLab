"""
URL configuration for the API app.
Enhanced with filtering, searching, and ordering endpoints.
"""

from django.urls import path
from . import views

urlpatterns = [
    # Book CRUD operations with filtering, searching, and ordering
    path('books/', views.BookListView.as_view(), name='book-list'),
    path('books/<int:pk>/', views.BookDetailView.as_view(), name='book-detail'),
    
    # Dedicated search endpoint
    path('books/search/', views.BookSearchView.as_view(), name='book-search'),
]
