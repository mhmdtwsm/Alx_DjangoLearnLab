from django.urls import path
from . import views

urlpatterns = [
    # Function-based views
    path('books/', views.book_list_view, name='book_list'),
    path('books/<int:pk>/', views.book_detail_view, name='book_detail'),
    path('books/create/', views.book_create_view, name='book_create'),
    path('books/<int:pk>/edit/', views.book_edit_view, name='book_edit'),
    path('books/<int:pk>/delete/', views.book_delete_view, name='book_delete'),
    
    # Class-based views (alternative routes)
    path('books-cbv/', views.BookListView.as_view(), name='book_list_cbv'),
    path('books-cbv/create/', views.BookCreateView.as_view(), name='book_create_cbv'),
    path('books-cbv/<int:pk>/edit/', views.BookUpdateView.as_view(), name='book_edit_cbv'),
    path('books-cbv/<int:pk>/delete/', views.BookDeleteView.as_view(), name='book_delete_cbv'),
    
    # Library management
    path('library/<int:library_id>/add-book/<int:book_id>/', views.library_add_book_view, name='library_add_book'),
    path('library/<int:library_id>/remove-book/<int:book_id>/', views.library_remove_book_view, name='library_remove_book'),
]
