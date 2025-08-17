from django.urls import path
from django.views.decorators.cache import cache_page
from django.views.decorators.vary import vary_on_headers
from . import views

# URL patterns with security considerations
urlpatterns = [
    # Main book list with caching for performance
    path('', 
         cache_page(60 * 5)(views.secure_book_list), 
         name='secure_book_list'),
    
    # Book creation with CSRF protection
    path('create/', 
         views.secure_book_create, 
         name='secure_book_create'),
    
    # Search endpoint with rate limiting considerations  
    path('search/', 
         views.secure_book_search, 
         name='book_search'),
    
    # Comment addition endpoint
    path('add-comment/', 
         views.secure_add_comment, 
         name='add_comment'),
    
    # Book detail with secure parameter handling
    path('book/<int:book_id>/', 
         views.secure_book_detail, 
         name='secure_book_detail'),
]

# Security notes:
# - All views implement CSRF protection
# - URL parameters are safely handled with get_object_or_404
# - No raw SQL queries in any view
# - Input validation implemented in forms and views
# - Rate limiting considerations included
# - Caching used appropriately for performance
