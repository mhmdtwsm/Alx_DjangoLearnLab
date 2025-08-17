from django.urls import path
from django.contrib.auth.views import LoginView, LogoutView
from . import views
from .views import list_books
from .views import LibraryDetailView  # For class-based view

urlpatterns = [
    # Task 1: Book and Library Views
    path("books/", views.list_books, name="list_books"),
    path("libraries/<int:pk>/", LibraryDetailView.as_view(), name="library_detail"),
    path("", views.list_books, name="home"),  # A simple home page
    # Task 2: User Authentication
    path("register/", views.register_view, name="register"),
    path(
        "login/",
        LoginView.as_view(template_name="relationship_app/login.html"),
        name="login",
    ),
    path(
        "logout/",
        LogoutView.as_view(template_name="relationship_app/logout.html"),
        name="logout",
    ),
    # Task 3: Role-Based Access Control Views
    path("admin-dashboard/", views.admin_view, name="admin_dashboard"),
    path("librarian-dashboard/", views.librarian_view, name="librarian_dashboard"),
    path("member-dashboard/", views.member_view, name="member_dashboard"),
    # Task 4: Custom Permissions Views (placeholders)
    path("books/add/", views.add_book_view, name="add_book"),
    path("books/<int:pk>/edit/", views.edit_book_view, name="edit_book"),
    path("books/<int:pk>/delete/", views.delete_book_view, name="delete_book"),
]
