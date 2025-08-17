from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

# Create a router and register our ViewSet with it
router = DefaultRouter()
router.register(r'books_all', views.BookViewSet, basename='book_all')

# URL patterns for the api app
urlpatterns = [
    # API overview page
    path('', views.api_overview, name='api-overview'),
    
    # Route for the BookList view (ListAPIView)
    path('books/', views.BookList.as_view(), name='book-list'),
    
    # Alternative function-based view
    path('books-alt/', views.book_list_function_view, name='book-list-alt'),
    
    # Include the router URLs for BookViewSet (all CRUD operations)
    path('', include(router.urls)),  # This includes all routes registered with the router
]
