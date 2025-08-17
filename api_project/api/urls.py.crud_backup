from django.urls import path
from . import views

# URL patterns for the api app
urlpatterns = [
    path('', views.api_overview, name='api-overview'),  # API overview page
    path('books/', views.BookList.as_view(), name='book-list'),  # Main book list endpoint
    path('books-alt/', views.book_list_function_view, name='book-list-alt'),  # Alternative function-based view
]
