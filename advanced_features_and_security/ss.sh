#!/bin/bash

# --- Project Setup Script for Django Project: django-models ---
# This script automates the creation of the directory structure and
# essential files for your "Deep Dive into Django Models and Views" project.

echo "Starting Django project directory and file setup..."

# Define the main project directory name
PROJECT_DIR="django-models"
# Define the Django app name
APP_DIR="relationship_app"

# 1. Create the main project directory
echo "Creating main project directory: $PROJECT_DIR/"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR" || { echo "Failed to enter $PROJECT_DIR. Exiting."; exit 1; }

# 2. Create the core Django project files (placeholders for django-admin)
echo "Creating core Django project files..."
mkdir -p "$PROJECT_DIR" # Create inner project directory for settings etc.
touch "$PROJECT_DIR/__init__.py"
touch "$PROJECT_DIR/settings.py"
touch "$PROJECT_DIR/urls.py"
touch "$PROJECT_DIR/wsgi.py"
touch "$PROJECT_DIR/asgi.py"
touch "manage.py"
touch "db.sqlite3" # Placeholder for database file

# Add basic content to settings.py
cat <<EOF > "$PROJECT_DIR/settings.py"
# Django settings for $PROJECT_DIR project.

import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = 'your-secret-key-here' # IMPORTANT: Change this in production!

DEBUG = True

ALLOWED_HOSTS = []

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    '$APP_DIR', # Add your app here
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = '$PROJECT_DIR.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = '$PROJECT_DIR.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',},
]

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_TZ = True

STATIC_URL = '/static/'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

LOGIN_REDIRECT_URL = '/' # Redirect to home after login
LOGOUT_REDIRECT_URL = '/login/' # Redirect to login after logout
EOF

# Add basic content to root urls.py
cat <<EOF > "$PROJECT_DIR/urls.py"
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('$APP_DIR.urls')), # Include app's URLs
]
EOF

# 3. Create the Django app directory
echo "Creating Django app directory: $APP_DIR/"
mkdir -p "$APP_DIR"
cd "$APP_DIR" || { echo "Failed to enter $APP_DIR. Exiting."; exit 1; }

# 4. Create essential app files
echo "Creating essential app files: __init__.py, models.py, views.py, urls.py, query_samples.py"
touch "__init__.py"
touch "admin.py" # Standard Django app file
touch "apps.py"  # Standard Django app file
touch "tests.py" # Standard Django app file
touch "models.py"
touch "views.py"
touch "urls.py"
touch "query_samples.py"

# Add basic content to models.py
cat <<EOF > "models.py"
from django.db import models
from django.contrib.auth.models import User

# Task 0: Author Model
class Author(models.Model):
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name

# Task 0 & 4: Book Model with Custom Permissions
class Book(models.Model):
    title = models.CharField(max_length=200)
    author = models.ForeignKey(Author, on_delete=models.CASCADE)
    publication_year = models.IntegerField(default=2000) # Added for template example

    class Meta:
        permissions = [
            ("can_add_book", "Can add book"),
            ("can_change_book", "Can change book"),
            ("can_delete_book", "Can delete book"),
        ]

    def __str__(self):
        return self.title

# Task 0: Library Model
class Library(models.Model):
    name = models.CharField(max_length=100)
    books = models.ManyToManyField(Book)

    def __str__(self):
        return self.name

# Task 0: Librarian Model
class Librarian(models.Model):
    name = models.CharField(max_length=100)
    library = models.OneToOneField(Library, on_delete=models.CASCADE)

    def __str__(self):
        return self.name

# Task 3: UserProfile Model for Role-Based Access Control
class UserProfile(models.Model):
    USER_ROLES = (
        ('Admin', 'Admin'),
        ('Librarian', 'Librarian'),
        ('Member', 'Member'),
    )
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    role = models.CharField(max_length=10, choices=USER_ROLES, default='Member')

    def __str__(self):
        return f"{self.user.username}'s Profile ({self.role})"

# Django Signal to create UserProfile automatically
from django.db.models.signals import post_save
from django.dispatch import receiver

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.create(user=instance)

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    instance.userprofile.save()

EOF

# Add basic content to views.py
cat <<EOF > "views.py"
from django.shortcuts import render, get_object_or_404, redirect
from django.views.generic import ListView, DetailView
from .models import Book, Library, UserProfile # Import new models
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django.contrib.auth import login, logout, authenticate
from django.contrib import messages
from django.contrib.auth.decorators import login_required, user_passes_test, permission_required
from django.urls import reverse_lazy # For class-based view redirects

# Task 1: Function-based View to list all books
def list_books(request):
    books = Book.objects.all()
    return render(request, 'relationship_app/list_books.html', {'books': books})

# Task 1: Class-based View to display library details
class LibraryDetailView(DetailView):
    model = Library
    template_name = 'relationship_app/library_detail.html'
    context_object_name = 'library'

# Task 2: User Registration View
def register_view(request):
    if request.method == 'POST':
        form = UserCreationForm(request.POST)
        if form.is_valid():
            user = form.save()
            # Automatically create UserProfile via signal
            messages.success(request, 'Registration successful! You can now log in.')
            return redirect('login')
        else:
            messages.error(request, 'Registration failed. Please correct the errors.')
    else:
        form = UserCreationForm()
    return render(request, 'relationship_app/register.html', {'form': form})

# Task 2: User Login View
def login_view(request):
    if request.method == 'POST':
        form = AuthenticationForm(request, data=request.POST)
        if form.is_valid():
            username = form.cleaned_data.get('username')
            password = form.cleaned_data.get('password')
            user = authenticate(username=username, password=password)
            if user is not None:
                login(request, user)
                messages.info(request, f"You are now logged in as {username}.")
                return redirect('home') # Redirect to a home page after login
            else:
                messages.error(request, "Invalid username or password.")
        else:
            messages.error(request, "Invalid username or password.")
    else:
        form = AuthenticationForm()
    return render(request, 'relationship_app/login.html', {'form': form})

# Task 2: User Logout View
@login_required
def logout_view(request):
    logout(request)
    messages.info(request, "You have been logged out.")
    return redirect('login')

# Helper function to check user roles
def is_admin(user):
    return user.is_authenticated and hasattr(user, 'userprofile') and user.userprofile.role == 'Admin'

def is_librarian(user):
    return user.is_authenticated and hasattr(user, 'userprofile') and user.userprofile.role == 'Librarian'

def is_member(user):
    return user.is_authenticated and hasattr(user, 'userprofile') and user.userprofile.role == 'Member'

# Task 3: Role-Based Views
@user_passes_test(is_admin, login_url='/login/')
@login_required(login_url='/login/')
def admin_view(request):
    return render(request, 'relationship_app/admin_view.html')

@user_passes_test(is_librarian, login_url='/login/')
@login_required(login_url='/login/')
def librarian_view(request):
    return render(request, 'relationship_app/librarian_view.html')

@user_passes_test(is_member, login_url='/login/')
@login_required(login_url='/login/')
def member_view(request):
    return render(request, 'relationship_app/member_view.html')

# Task 4: Views for Book Operations with Custom Permissions
# Placeholder for book creation view
@permission_required('relationship_app.can_add_book', login_url='/login/')
@login_required(login_url='/login/')
def add_book_view(request):
    # This would typically involve a form to add a book
    return render(request, 'relationship_app/add_book.html') # Need to create this template

# Placeholder for book editing view
@permission_required('relationship_app.can_change_book', login_url='/login/')
@login_required(login_url='/login/')
def edit_book_view(request, pk):
    book = get_object_or_404(Book, pk=pk)
    # This would typically involve a form to edit a book
    return render(request, 'relationship_app/edit_book.html', {'book': book}) # Need to create this template

# Placeholder for book deletion view
@permission_required('relationship_app.can_delete_book', login_url='/login/')
@login_required(login_url='/login/')
def delete_book_view(request, pk):
    book = get_object_or_404(Book, pk=pk)
    # This would typically involve a confirmation for deletion
    if request.method == 'POST':
        book.delete()
        messages.success(request, 'Book deleted successfully.')
        return redirect('list_books')
    return render(request, 'relationship_app/delete_book_confirm.html', {'book': book}) # Need to create this template
EOF

# Add basic content to urls.py
cat <<EOF > "urls.py"
from django.urls import path
from . import views
from .views import LibraryDetailView # For class-based view

urlpatterns = [
    # Task 1: Book and Library Views
    path('books/', views.list_books, name='list_books'),
    path('libraries/<int:pk>/', LibraryDetailView.as_view(), name='library_detail'),
    path('', views.list_books, name='home'), # A simple home page

    # Task 2: User Authentication
    path('register/', views.register_view, name='register'),
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),

    # Task 3: Role-Based Access Control Views
    path('admin-dashboard/', views.admin_view, name='admin_dashboard'),
    path('librarian-dashboard/', views.librarian_view, name='librarian_dashboard'),
    path('member-dashboard/', views.member_view, name='member_dashboard'),

    # Task 4: Custom Permissions Views (placeholders)
    path('books/add/', views.add_book_view, name='add_book'),
    path('books/<int:pk>/edit/', views.edit_book_view, name='edit_book'),
    path('books/<int:pk>/delete/', views.delete_book_view, name='delete_book'),
]
EOF

# Add basic content to query_samples.py
cat <<EOF > "query_samples.py"
import os
import django

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', '$PROJECT_DIR.settings')
django.setup()

from $APP_DIR.models import Author, Book, Library, Librarian, User, UserProfile

def run_queries():
    print("--- Running Sample Queries ---")

    # Clear existing data for a clean run (optional, for testing)
    Author.objects.all().delete()
    Book.objects.all().delete()
    Library.objects.all().delete()
    Librarian.objects.all().delete()
    User.objects.filter(is_superuser=False).delete() # Don't delete superuser

    # Create sample data
    author1 = Author.objects.create(name="Jane Austen")
    author2 = Author.objects.create(name="George Orwell")

    book1 = Book.objects.create(title="Pride and Prejudice", author=author1, publication_year=1813)
    book2 = Book.objects.create(title="1984", author=author2, publication_year=1949)
    book3 = Book.objects.create(title="Sense and Sensibility", author=author1, publication_year=1811)

    library1 = Library.objects.create(name="Central Library")
    library1.books.add(book1, book2)

    library2 = Library.objects.create(name="Community Bookshelf")
    library2.books.add(book3)

    librarian1 = Librarian.objects.create(name="Alice Smith", library=library1)
    librarian2 = Librarian.objects.create(name="Bob Johnson", library=library2)

    # Create test users (profiles created by signal)
    user_admin = User.objects.create_user(username='admin_user', email='admin@example.com', password='password123')
    user_admin.is_staff = True # Needed for admin panel access
    user_admin.is_superuser = True # Make this user a superuser for initial setup
    user_admin.save()
    user_admin.userprofile.role = 'Admin'
    user_admin.userprofile.save()

    user_librarian = User.objects.create_user(username='librarian_user', email='librarian@example.com', password='password123')
    user_librarian.userprofile.role = 'Librarian'
    user_librarian.userprofile.save()

    user_member = User.objects.create_user(username='member_user', email='member@example.com', password='password123')
    user_member.userprofile.role = 'Member'
    user_member.userprofile.save()


    # --- Task 0: Implement Sample Queries ---

    print("\nQuery 1: All books by a specific author (Jane Austen)")
    jane_austen_books = Book.objects.filter(author=author1)
    for book in jane_austen_books:
        print(f"- {book.title} by {book.author.name}")

    print("\nQuery 2: All books in a library (Central Library)")
    central_library_books = library1.books.all()
    for book in central_library_books:
        print(f"- {book.title} by {book.author.name}")

    print("\nQuery 3: Retrieve the librarian for a library (Central Library)")
    central_librarian = library1.librarian
    print(f"- The librarian for Central Library is: {central_librarian.name}")

    print("\n--- Sample Data Created and Queries Executed ---")

if __name__ == "__main__":
    run_queries()
EOF

# 5. Create templates directory structure
echo "Creating templates directory structure: templates/$APP_DIR/"
mkdir -p "templates/$APP_DIR"

# 6. Create HTML template files with content
echo "Creating HTML template files..."

# list_books.html
cat <<EOF > "templates/$APP_DIR/list_books.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>List of Books</title>
    <style>
        body { font-family: sans-serif; margin: 20px; background-color: #f4f4f4; color: #333; }
        h1 { color: #0056b3; }
        ul { list-style-type: none; padding: 0; }
        li { background-color: #fff; border: 1px solid #ddd; margin-bottom: 5px; padding: 10px; border-radius: 5px; }
        .nav-links a { margin-right: 15px; text-decoration: none; color: #007bff; }
        .nav-links a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="nav-links">
        <a href="{% url 'list_books' %}">All Books</a> |
        <a href="{% url 'register' %}">Register</a> |
        {% if user.is_authenticated %}
            <a href="{% url 'logout' %}">Logout ({{ user.username }})</a> |
            {% if user.userprofile.role == 'Admin' %}<a href="{% url 'admin_dashboard' %}">Admin Dashboard</a> |{% endif %}
            {% if user.userprofile.role == 'Librarian' %}<a href="{% url 'librarian_dashboard' %}">Librarian Dashboard</a> |{% endif %}
            {% if user.userprofile.role == 'Member' %}<a href="{% url 'member_dashboard' %}">Member Dashboard</a> |{% endif %}
            <a href="{% url 'add_book' %}">Add Book</a>
        {% else %}
            <a href="{% url 'login' %}">Login</a>
        {% endif %}
    </div>
    <h1>Books Available:</h1>
    <ul>
        {% for book in books %}
        <li>
            {{ book.title }} by {{ book.author.name }} (Published {{ book.publication_year }})
            {% if user.is_authenticated and user.has_perm 'relationship_app.can_change_book' %}
                <a href="{% url 'edit_book' book.pk %}" style="margin-left: 10px; color: green;">Edit</a>
            {% endif %}
            {% if user.is_authenticated and user.has_perm 'relationship_app.can_delete_book' %}
                <a href="{% url 'delete_book' book.pk %}" style="color: red;">Delete</a>
            {% endif %}
        </li>
        {% empty %}
        <li>No books found.</li>
        {% endfor %}
    </ul>
</body>
</html>
EOF

# library_detail.html
cat <<EOF > "templates/$APP_DIR/library_detail.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Library Detail</title>
    <style>
        body { font-family: sans-serif; margin: 20px; background-color: #f4f4f4; color: #333; }
        h1, h2 { color: #0056b3; }
        ul { list-style-type: none; padding: 0; }
        li { background-color: #fff; border: 1px solid #ddd; margin-bottom: 5px; padding: 10px; border-radius: 5px; }
        a { color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <a href="{% url 'list_books' %}">Back to Books</a>
    <h1>Library: {{ library.name }}</h1>
    <h2>Books in Library:</h2>
    <ul>
        {% for book in library.books.all %}
        <li>{{ book.title }} by {{ book.author.name }} (Published {{ book.publication_year }})</li>
        {% endfor %}
    </ul>
</body>
</html>
EOF

# login.html
cat <<EOF > "templates/$APP_DIR/login.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login</title>
    <style>
        body { font-family: sans-serif; margin: 20px; background-color: #f4f4f4; color: #333; }
        h1 { color: #0056b3; }
        form { background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 400px; margin: 20px auto; }
        p { margin-bottom: 10px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input[type="text"], input[type="password"] { width: calc(100% - 22px); padding: 10px; margin-bottom: 10px; border: 1px solid #ddd; border-radius: 4px; }
        button { background-color: #007bff; color: white; padding: 10px 15px; border: none; border-radius: 5px; cursor: pointer; font-size: 16px; }
        button:hover { background-color: #0056b3; }
        a { color: #007bff; text-decoration: none; display: block; text-align: center; margin-top: 10px; }
        a:hover { text-decoration: underline; }
        .errorlist { color: red; list-style-type: none; padding: 0; margin-top: -10px; margin-bottom: 10px; }
    </style>
</head>
<body>
    <h1>Login</h1>
    <form method="post">
        {% csrf_token %}
        {{ form.as_p }}
        {% if messages %}
            <ul class="messages">
                {% for message in messages %}
                    <li{% if message.tags %} class="{{ message.tags }}"{% endif %}>{{ message }}</li>
                {% endfor %}
            </ul>
        {% endif %}
        <button type="submit">Login</button>
    </form>
    <a href="{% url 'register' %}">Register</a>
</body>
</html>
EOF

# logout.html
cat <<EOF > "templates/$APP_DIR/logout.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Logout</title>
    <style>
        body { font-family: sans-serif; margin: 20px; background-color: #f4f4f4; color: #333; text-align: center; }
        h1 { color: #0056b3; }
        a { color: #007bff; text-decoration: none; margin-top: 20px; display: inline-block; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>You have been logged out</h1>
    <a href="{% url 'login' %}">Login again</a>
</body>
</html>
EOF

# register.html
cat <<EOF > "templates/$APP_DIR/register.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register</title>
    <style>
        body { font-family: sans-serif; margin: 20px; background-color: #f4f4f4; color: #333; }
        h1 { color: #0056b3; }
        form { background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 400px; margin: 20px auto; }
        p { margin-bottom: 10px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input[type="text"], input[type="password"], input[type="email"] { width: calc(100% - 22px); padding: 10px; margin-bottom: 10px; border: 1px solid #ddd; border-radius: 4px; }
        button { background-color: #28a745; color: white; padding: 10px 15px; border: none; border-radius: 5px; cursor: pointer; font-size: 16px; }
        button:hover { background-color: #218838; }
        .errorlist { color: red; list-style-type: none; padding: 0; margin-top: -10px; margin-bottom: 10px; }
    </style>
</head>
<body>
    <h1>Register</h1>
    <form method="post">
        {% csrf_token %}
        {{ form.as_p }}
        {% if messages %}
            <ul class="messages">
                {% for message in messages %}
                    <li{% if message.tags %} class="{{ message.tags }}"{% endif %}>{{ message }}</li>
                {% endfor %}
            </ul>
        {% endif %}
        <button type="submit">Register</button>
    </form>
</body>
</html>
EOF

# admin_view.html
cat <<EOF > "templates/$APP_DIR/admin_view.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard</title>
    <style>
        body { font-family: sans-serif; margin: 20px; background-color: #e6f7ff; color: #333; }
        h1 { color: #004085; }
        p { background-color: #cce5ff; border: 1px solid #b8daff; padding: 15px; border-radius: 5px; }
        a { color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Welcome, Admin!</h1>
    <p>This is the exclusive dashboard for administrators.</p>
    <a href="{% url 'home' %}">Back to Home</a> | <a href="{% url 'logout' %}">Logout</a>
</body>
</html>
EOF

# librarian_view.html
cat <<EOF > "templates/$APP_DIR/librarian_view.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Librarian Dashboard</title>
    <style>
        body { font-family: sans-serif; margin: 20px; background-color: #e2f7e2; color: #333; }
        h1 { color: #28a745; }
        p { background-color: #d4edda; border: 1px solid #c3e6cb; padding: 15px; border-radius: 5px; }
        a { color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Welcome, Librarian!</h1>
    <p>This is the dashboard for librarians, where you can manage books and users.</p>
    <a href="{% url 'home' %}">Back to Home</a> | <a href="{% url 'logout' %}">Logout</a>
</body>
</html>
EOF

# member_view.html
cat <<EOF > "templates/$APP_DIR/member_view.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Member Dashboard</title>
    <style>
        body { font-family: sans-serif; margin: 20px; background-color: #fff3cd; color: #333; }
        h1 { color: #856404; }
        p { background-color: #ffeeba; border: 1px solid #ffc107; padding: 15px; border-radius: 5px; }
        a { color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Welcome, Member!</h1>
    <p>This is the dashboard for members.</p>
    <a href="{% url 'home' %}">Back to Home</a> | <a href="{% url 'logout' %}">Logout</a>
</body>
</html>
EOF

# add_book.html (placeholder for Task 4)
cat <<EOF > "templates/$APP_DIR/add_book.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Add New Book</title>
    <style>
        body { font-family: sans-serif; margin: 20px; background-color: #f4f4f4; color: #333; }
        h1 { color: #0056b3; }
        p { margin-bottom: 10px; }
        a { color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Add New Book</h1>
    <p>This page is for adding new books. (Only accessible with 'can_add_book' permission)</p>
    <a href="{% url 'list_books' %}">Back to Books List</a>
</body>
</html>
EOF

# edit_book.html (placeholder for Task 4)
cat <<EOF > "templates/$APP_DIR/edit_book.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Book</title>
    <style>
        body { font-family: sans-serif; margin: 20px; background-color: #f4f4f4; color: #333; }
        h1 { color: #0056b3; }
        p { margin-bottom: 10px; }
        a { color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Edit Book: {{ book.title }}</h1>
    <p>This page is for editing book details. (Only accessible with 'can_change_book' permission)</p>
    <a href="{% url 'list_books' %}">Back to Books List</a>
</body>
</html>
EOF

# delete_book_confirm.html (placeholder for Task 4)
cat <<EOF > "templates/$APP_DIR/delete_book_confirm.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Confirm Delete Book</title>
    <style>
        body { font-family: sans-serif; margin: 20px; background-color: #f4f4f4; color: #333; }
        h1 { color: #dc3545; }
        p { margin-bottom: 15px; }
        form { display: inline-block; }
        button { background-color: #dc3545; color: white; padding: 10px 15px; border: none; border-radius: 5px; cursor: pointer; font-size: 16px; }
        button:hover { background-color: #c82333; }
        a { color: #007bff; text-decoration: none; margin-left: 15px; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Confirm Deletion</h1>
    <p>Are you sure you want to delete the book: "{{ book.title }}"?</p>
    <form method="post">
        {% csrf_token %}
        <button type="submit">Yes, Delete</button>
    </form>
    <a href="{% url 'list_books' %}">Cancel</a>
</body>
</html>
EOF


echo "All directories and files have been created."
echo "Navigate to the '$PROJECT_DIR' directory to continue your Django project."
echo "To initialize the Django project and run migrations, you would typically run:"
echo "  cd $PROJECT_DIR"
echo "  python3 manage.py makemigrations $APP_DIR"
echo "  python3 manage.py migrate"
echo "  python3 manage.py createsuperuser (to create an admin user)"
echo "  python3 manage.py runserver"

echo ""
echo "To run the sample queries for Task 0:"
echo "  cd $APP_DIR"
echo "  python3 query_samples.py"

cd ../.. # Go back to the original directory where the script was run
