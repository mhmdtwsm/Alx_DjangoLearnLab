#!/bin/bash

# Django Permissions and Groups Setup Script
# This script sets up a comprehensive permissions system for the LibraryProject

echo "🚀 Setting up Django Permissions and Groups System..."
echo "=================================================="

# Define the base directory
BASE_DIR="/home/mhmd/study/alx/Alx_DjangoLearnLab/advanced_features_and_security/LibraryProject"

# Check if the base directory exists
if [ ! -d "$BASE_DIR" ]; then
    echo "❌ Error: Base directory $BASE_DIR does not exist!"
    exit 1
fi

echo "📁 Working in: $BASE_DIR"

# 1. Update bookshelf models.py with custom permissions
echo "📝 Step 1: Adding custom permissions to models..."

cat > "$BASE_DIR/bookshelf/models.py" << 'EOF'
from django.db import models
from django.contrib.auth.models import AbstractUser

class CustomUser(AbstractUser):
    date_of_birth = models.DateField(null=True, blank=True)
    profile_photo = models.ImageField(upload_to='profile_photos/', null=True, blank=True)

class Book(models.Model):
    title = models.CharField(max_length=200)
    author = models.CharField(max_length=100)
    publication_year = models.IntegerField()
    isbn = models.CharField(max_length=13, unique=True)
    pages = models.IntegerField(default=0)
    cover = models.ImageField(upload_to='book_covers/', null=True, blank=True)
    language = models.CharField(max_length=50, default='English')
    
    class Meta:
        permissions = [
            ("can_view", "Can view book"),
            ("can_create", "Can create book"),
            ("can_edit", "Can edit book"),
            ("can_delete", "Can delete book"),
        ]
    
    def __str__(self):
        return f"{self.title} by {self.author}"

class Library(models.Model):
    name = models.CharField(max_length=200)
    books = models.ManyToManyField(Book)
    
    class Meta:
        permissions = [
            ("can_add_book", "Can add book to library"),
            ("can_remove_book", "Can remove book from library"),
        ]
    
    def __str__(self):
        return self.name

class Librarian(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE)
    library = models.ForeignKey(Library, on_delete=models.CASCADE)
    
    def __str__(self):
        return f"{self.user.username} - {self.library.name}"
EOF

echo "✅ Updated bookshelf/models.py with custom permissions"

# 2. Update bookshelf views.py with permission-protected views
echo "📝 Step 2: Creating permission-protected views..."

cat > "$BASE_DIR/bookshelf/views.py" << 'EOF'
from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import permission_required
from django.contrib.auth.mixins import PermissionRequiredMixin
from django.contrib import messages
from django.views.generic import ListView, CreateView, UpdateView, DeleteView
from django.urls import reverse_lazy
from .models import Book, Library
from .forms import BookForm

# Function-based views with permission decorators
@permission_required('bookshelf.can_view', raise_exception=True)
def book_list_view(request):
    """View to display all books - requires can_view permission"""
    books = Book.objects.all()
    return render(request, 'bookshelf/book_list.html', {'books': books})

@permission_required('bookshelf.can_view', raise_exception=True)
def book_detail_view(request, pk):
    """View to display a single book - requires can_view permission"""
    book = get_object_or_404(Book, pk=pk)
    return render(request, 'bookshelf/book_detail.html', {'book': book})

@permission_required('bookshelf.can_create', raise_exception=True)
def book_create_view(request):
    """View to create a new book - requires can_create permission"""
    if request.method == 'POST':
        form = BookForm(request.POST, request.FILES)
        if form.is_valid():
            form.save()
            messages.success(request, 'Book created successfully!')
            return redirect('book_list')
    else:
        form = BookForm()
    return render(request, 'bookshelf/book_form.html', {'form': form, 'action': 'Create'})

@permission_required('bookshelf.can_edit', raise_exception=True)
def book_edit_view(request, pk):
    """View to edit a book - requires can_edit permission"""
    book = get_object_or_404(Book, pk=pk)
    if request.method == 'POST':
        form = BookForm(request.POST, request.FILES, instance=book)
        if form.is_valid():
            form.save()
            messages.success(request, 'Book updated successfully!')
            return redirect('book_detail', pk=book.pk)
    else:
        form = BookForm(instance=book)
    return render(request, 'bookshelf/book_form.html', {'form': form, 'action': 'Edit', 'book': book})

@permission_required('bookshelf.can_delete', raise_exception=True)
def book_delete_view(request, pk):
    """View to delete a book - requires can_delete permission"""
    book = get_object_or_404(Book, pk=pk)
    if request.method == 'POST':
        book.delete()
        messages.success(request, 'Book deleted successfully!')
        return redirect('book_list')
    return render(request, 'bookshelf/book_confirm_delete.html', {'book': book})

# Class-based views with permission mixins
class BookListView(PermissionRequiredMixin, ListView):
    """Class-based view for listing books"""
    model = Book
    template_name = 'bookshelf/book_list.html'
    context_object_name = 'books'
    permission_required = 'bookshelf.can_view'

class BookCreateView(PermissionRequiredMixin, CreateView):
    """Class-based view for creating books"""
    model = Book
    form_class = BookForm
    template_name = 'bookshelf/book_form.html'
    success_url = reverse_lazy('book_list')
    permission_required = 'bookshelf.can_create'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['action'] = 'Create'
        return context

class BookUpdateView(PermissionRequiredMixin, UpdateView):
    """Class-based view for updating books"""
    model = Book
    form_class = BookForm
    template_name = 'bookshelf/book_form.html'
    permission_required = 'bookshelf.can_edit'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['action'] = 'Edit'
        return context

class BookDeleteView(PermissionRequiredMixin, DeleteView):
    """Class-based view for deleting books"""
    model = Book
    template_name = 'bookshelf/book_confirm_delete.html'
    success_url = reverse_lazy('book_list')
    permission_required = 'bookshelf.can_delete'

# Library management views with permissions
@permission_required('bookshelf.can_add_book', raise_exception=True)
def library_add_book_view(request, library_id, book_id):
    """Add a book to a library - requires can_add_book permission"""
    library = get_object_or_404(Library, pk=library_id)
    book = get_object_or_404(Book, pk=book_id)
    library.books.add(book)
    messages.success(request, f'Book "{book.title}" added to library "{library.name}"')
    return redirect('library_detail', pk=library_id)

@permission_required('bookshelf.can_remove_book', raise_exception=True)
def library_remove_book_view(request, library_id, book_id):
    """Remove a book from a library - requires can_remove_book permission"""
    library = get_object_or_404(Library, pk=library_id)
    book = get_object_or_404(Book, pk=book_id)
    library.books.remove(book)
    messages.success(request, f'Book "{book.title}" removed from library "{library.name}"')
    return redirect('library_detail', pk=library_id)
EOF

echo "✅ Updated bookshelf/views.py with permission-protected views"

# 3. Create forms.py for the bookshelf app
echo "📝 Step 3: Creating forms.py..."

cat > "$BASE_DIR/bookshelf/forms.py" << 'EOF'
from django import forms
from .models import Book, Library

class BookForm(forms.ModelForm):
    class Meta:
        model = Book
        fields = ['title', 'author', 'publication_year', 'isbn', 'pages', 'cover', 'language']
        widgets = {
            'title': forms.TextInput(attrs={'class': 'form-control'}),
            'author': forms.TextInput(attrs={'class': 'form-control'}),
            'publication_year': forms.NumberInput(attrs={'class': 'form-control'}),
            'isbn': forms.TextInput(attrs={'class': 'form-control'}),
            'pages': forms.NumberInput(attrs={'class': 'form-control'}),
            'cover': forms.FileInput(attrs={'class': 'form-control'}),
            'language': forms.TextInput(attrs={'class': 'form-control'}),
        }

class LibraryForm(forms.ModelForm):
    class Meta:
        model = Library
        fields = ['name', 'books']
        widgets = {
            'name': forms.TextInput(attrs={'class': 'form-control'}),
            'books': forms.CheckboxSelectMultiple(),
        }
EOF

echo "✅ Created bookshelf/forms.py"

# 4. Create URLs configuration for bookshelf
echo "📝 Step 4: Creating URL configurations..."

cat > "$BASE_DIR/bookshelf/urls.py" << 'EOF'
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
EOF

echo "✅ Created bookshelf/urls.py"

# 5. Update main project URLs
echo "📝 Step 5: Updating main project URLs..."

cat > "$BASE_DIR/LibraryProject/urls.py" << 'EOF'
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('bookshelf/', include('bookshelf.urls')),
    path('relationship/', include('relationship_app.urls')),
    path('', include('bookshelf.urls')),  # Default to bookshelf app
]

# Serve media files during development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
EOF

echo "✅ Updated main project URLs"

# 6. Create template directories and files
echo "📝 Step 6: Creating template files..."

# Create templates directory structure
mkdir -p "$BASE_DIR/bookshelf/templates/bookshelf"

# Base template
cat > "$BASE_DIR/bookshelf/templates/bookshelf/base.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}Library Management{% endblock %}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="{% url 'book_list' %}">Library Management</a>
            <div class="navbar-nav ms-auto">
                {% if user.is_authenticated %}
                    <span class="navbar-text me-3">Hello, {{ user.username }}!</span>
                    <a class="nav-link" href="{% url 'admin:logout' %}">Logout</a>
                {% else %}
                    <a class="nav-link" href="{% url 'admin:login' %}">Login</a>
                {% endif %}
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        {% if messages %}
            {% for message in messages %}
                <div class="alert alert-{{ message.tags }} alert-dismissible fade show" role="alert">
                    {{ message }}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            {% endfor %}
        {% endif %}

        {% block content %}
        {% endblock %}
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
EOF

# Book list template
cat > "$BASE_DIR/bookshelf/templates/bookshelf/book_list.html" << 'EOF'
{% extends 'bookshelf/base.html' %}

{% block title %}Books - Library Management{% endblock %}

{% block content %}
<div class="d-flex justify-content-between align-items-center mb-4">
    <h2>Books</h2>
    {% if perms.bookshelf.can_create %}
        <a href="{% url 'book_create' %}" class="btn btn-primary">Add New Book</a>
    {% endif %}
</div>

<div class="row">
    {% for book in books %}
        <div class="col-md-4 mb-3">
            <div class="card">
                {% if book.cover %}
                    <img src="{{ book.cover.url }}" class="card-img-top" style="height: 200px; object-fit: cover;">
                {% endif %}
                <div class="card-body">
                    <h5 class="card-title">{{ book.title }}</h5>
                    <p class="card-text">
                        <strong>Author:</strong> {{ book.author }}<br>
                        <strong>Year:</strong> {{ book.publication_year }}<br>
                        <strong>Pages:</strong> {{ book.pages }}
                    </p>
                    <div class="btn-group" role="group">
                        {% if perms.bookshelf.can_view %}
                            <a href="{% url 'book_detail' book.pk %}" class="btn btn-outline-primary btn-sm">View</a>
                        {% endif %}
                        {% if perms.bookshelf.can_edit %}
                            <a href="{% url 'book_edit' book.pk %}" class="btn btn-outline-secondary btn-sm">Edit</a>
                        {% endif %}
                        {% if perms.bookshelf.can_delete %}
                            <a href="{% url 'book_delete' book.pk %}" class="btn btn-outline-danger btn-sm">Delete</a>
                        {% endif %}
                    </div>
                </div>
            </div>
        </div>
    {% empty %}
        <div class="col-12">
            <p class="text-muted">No books available.</p>
        </div>
    {% endfor %}
</div>
{% endblock %}
EOF

# Book detail template
cat > "$BASE_DIR/bookshelf/templates/bookshelf/book_detail.html" << 'EOF'
{% extends 'bookshelf/base.html' %}

{% block title %}{{ book.title }} - Library Management{% endblock %}

{% block content %}
<div class="row">
    <div class="col-md-4">
        {% if book.cover %}
            <img src="{{ book.cover.url }}" class="img-fluid rounded" alt="{{ book.title }}">
        {% else %}
            <div class="bg-light p-5 text-center rounded">
                <p class="text-muted">No cover available</p>
            </div>
        {% endif %}
    </div>
    <div class="col-md-8">
        <h2>{{ book.title }}</h2>
        <p><strong>Author:</strong> {{ book.author }}</p>
        <p><strong>Publication Year:</strong> {{ book.publication_year }}</p>
        <p><strong>ISBN:</strong> {{ book.isbn }}</p>
        <p><strong>Pages:</strong> {{ book.pages }}</p>
        <p><strong>Language:</strong> {{ book.language }}</p>
        
        <div class="mt-4">
            <a href="{% url 'book_list' %}" class="btn btn-secondary">Back to List</a>
            {% if perms.bookshelf.can_edit %}
                <a href="{% url 'book_edit' book.pk %}" class="btn btn-primary">Edit</a>
            {% endif %}
            {% if perms.bookshelf.can_delete %}
                <a href="{% url 'book_delete' book.pk %}" class="btn btn-danger">Delete</a>
            {% endif %}
        </div>
    </div>
</div>
{% endblock %}
EOF

# Book form template
cat > "$BASE_DIR/bookshelf/templates/bookshelf/book_form.html" << 'EOF'
{% extends 'bookshelf/base.html' %}

{% block title %}{{ action }} Book - Library Management{% endblock %}

{% block content %}
<h2>{{ action }} Book</h2>

<form method="post" enctype="multipart/form-data">
    {% csrf_token %}
    <div class="row">
        <div class="col-md-6">
            <div class="mb-3">
                <label for="{{ form.title.id_for_label }}" class="form-label">Title</label>
                {{ form.title }}
            </div>
            <div class="mb-3">
                <label for="{{ form.author.id_for_label }}" class="form-label">Author</label>
                {{ form.author }}
            </div>
            <div class="mb-3">
                <label for="{{ form.publication_year.id_for_label }}" class="form-label">Publication Year</label>
                {{ form.publication_year }}
            </div>
        </div>
        <div class="col-md-6">
            <div class="mb-3">
                <label for="{{ form.isbn.id_for_label }}" class="form-label">ISBN</label>
                {{ form.isbn }}
            </div>
            <div class="mb-3">
                <label for="{{ form.pages.id_for_label }}" class="form-label">Pages</label>
                {{ form.pages }}
            </div>
            <div class="mb-3">
                <label for="{{ form.language.id_for_label }}" class="form-label">Language</label>
                {{ form.language }}
            </div>
        </div>
    </div>
    <div class="mb-3">
        <label for="{{ form.cover.id_for_label }}" class="form-label">Cover Image</label>
        {{ form.cover }}
    </div>
    
    <button type="submit" class="btn btn-primary">{{ action }} Book</button>
    <a href="{% url 'book_list' %}" class="btn btn-secondary">Cancel</a>
</form>
{% endblock %}
EOF

# Book delete confirmation template
cat > "$BASE_DIR/bookshelf/templates/bookshelf/book_confirm_delete.html" << 'EOF'
{% extends 'bookshelf/base.html' %}

{% block title %}Delete Book - Library Management{% endblock %}

{% block content %}
<h2>Delete Book</h2>

<div class="alert alert-warning">
    <h4>Are you sure you want to delete "{{ book.title }}"?</h4>
    <p>This action cannot be undone.</p>
</div>

<div class="row">
    <div class="col-md-4">
        {% if book.cover %}
            <img src="{{ book.cover.url }}" class="img-fluid rounded" alt="{{ book.title }}">
        {% endif %}
    </div>
    <div class="col-md-8">
        <h4>{{ book.title }}</h4>
        <p><strong>Author:</strong> {{ book.author }}</p>
        <p><strong>Publication Year:</strong> {{ book.publication_year }}</p>
        <p><strong>ISBN:</strong> {{ book.isbn }}</p>
    </div>
</div>

<form method="post" class="mt-3">
    {% csrf_token %}
    <button type="submit" class="btn btn-danger">Yes, Delete</button>
    <a href="{% url 'book_detail' book.pk %}" class="btn btn-secondary">Cancel</a>
</form>
{% endblock %}
EOF

echo "✅ Created template files"

# 7. Create management command for setting up groups and permissions
echo "📝 Step 7: Creating management command for groups setup..."

mkdir -p "$BASE_DIR/bookshelf/management"
mkdir -p "$BASE_DIR/bookshelf/management/commands"

# Create __init__.py files
touch "$BASE_DIR/bookshelf/management/__init__.py"
touch "$BASE_DIR/bookshelf/management/commands/__init__.py"

cat > "$BASE_DIR/bookshelf/management/commands/setup_groups.py" << 'EOF'
from django.core.management.base import BaseCommand
from django.contrib.auth.models import Group, Permission
from django.contrib.contenttypes.models import ContentType
from bookshelf.models import Book, Library

class Command(BaseCommand):
    help = 'Create user groups and assign permissions'

    def handle(self, *args, **options):
        # Create groups
        editors_group, created = Group.objects.get_or_create(name='Editors')
        viewers_group, created = Group.objects.get_or_create(name='Viewers')
        admins_group, created = Group.objects.get_or_create(name='Admins')

        # Get content types
        book_content_type = ContentType.objects.get_for_model(Book)
        library_content_type = ContentType.objects.get_for_model(Library)

        # Get or create permissions
        can_view_book, _ = Permission.objects.get_or_create(
            codename='can_view',
            name='Can view book',
            content_type=book_content_type,
        )
        can_create_book, _ = Permission.objects.get_or_create(
            codename='can_create',
            name='Can create book',
            content_type=book_content_type,
        )
        can_edit_book, _ = Permission.objects.get_or_create(
            codename='can_edit',
            name='Can edit book',
            content_type=book_content_type,
        )
        can_delete_book, _ = Permission.objects.get_or_create(
            codename='can_delete',
            name='Can delete book',
            content_type=book_content_type,
        )
        can_add_book_to_library, _ = Permission.objects.get_or_create(
            codename='can_add_book',
            name='Can add book to library',
            content_type=library_content_type,
        )
        can_remove_book_from_library, _ = Permission.objects.get_or_create(
            codename='can_remove_book',
            name='Can remove book from library',
            content_type=library_content_type,
        )

        # Assign permissions to groups
        # Viewers: can only view
        viewers_group.permissions.clear()
        viewers_group.permissions.add(can_view_book)

        # Editors: can view, create, and edit (but not delete)
        editors_group.permissions.clear()
        editors_group.permissions.add(can_view_book, can_create_book, can_edit_book)
        editors_group.permissions.add(can_add_book_to_library, can_remove_book_from_library)

        # Admins: can do everything
        admins_group.permissions.clear()
        admins_group.permissions.add(
            can_view_book, can_create_book, can_edit_book, can_delete_book,
            can_add_book_to_library, can_remove_book_from_library
        )

        self.stdout.write(
            self.style.SUCCESS(
                'Successfully created groups and assigned permissions:\n'
                '- Viewers: can_view\n'
                '- Editors: can_view, can_create, can_edit, can_add_book, can_remove_book\n'
                '- Admins: all permissions'
            )
        )
EOF

echo "✅ Created management command for group setup"

# 8. Create permission setup documentation
echo "📝 Step 8: Creating documentation..."

cat > "$BASE_DIR/PERMISSIONS_SETUP.md" << 'EOF'
# Django Permissions and Groups Setup Documentation

## Overview
This document explains how the permissions and groups system is configured and used in the LibraryProject Django application.

## Custom Permissions

### Book Model Permissions
The Book model includes the following custom permissions:
- `can_view`: Allows users to view books
- `can_create`: Allows users to create new books
- `can_edit`: Allows users to edit existing books
- `can_delete`: Allows users to delete books

### Library Model Permissions
The Library model includes the following custom permissions:
- `can_add_book`: Allows users to add books to a library
- `can_remove_book`: Allows users to remove books from a library

## User Groups

### 1. Viewers Group
- **Permissions**: `can_view`
- **Description**: Can only view books and their details
- **Use Case**: Regular users who need read-only access

### 2. Editors Group
- **Permissions**: `can_view`, `can_create`, `can_edit`, `can_add_book`, `can_remove_book`
- **Description**: Can view, create, and edit books, manage library contents
- **Use Case**: Content managers and librarians

### 3. Admins Group
- **Permissions**: All permissions (including `can_delete`)
- **Description**: Full access to all functionality
- **Use Case**: System administrators

## Setting Up Groups and Permissions

### Automatic Setup
Run the management command to automatically create groups and assign permissions:
```bash
python manage.py setup_groups
```

### Manual Setup via Django Admin
1. Go to Django Admin → Groups
2. Create the following groups: Viewers, Editors, Admins
3. Assign permissions as described above

## Assigning Users to Groups

### Via Django Admin
1. Go to Django Admin → Users
2. Select a user
3. In the "Groups" section, add the user to appropriate groups

### Programmatically
```python
from django.contrib.auth.models import Group
from bookshelf.models import CustomUser

user = CustomUser.objects.get(username='example_user')
editors_group = Group.objects.get(name='Editors')
user.groups.add(editors_group)
```

## Views and Permission Enforcement

### Function-Based Views
Views use the `@permission_required` decorator:
```python
@permission_required('bookshelf.can_edit', raise_exception=True)
def book_edit_view(request, pk):
    # View logic here
```

### Class-Based Views
Views use the `PermissionRequiredMixin`:
```python
class BookCreateView(PermissionRequiredMixin, CreateView):
    permission_required = 'bookshelf.can_create'
    # View logic here
```

## Template Permission Checks

Templates check permissions using the `perms` context variable:
```html
{% if perms.bookshelf.can_edit %}
    <a href="{% url 'book_edit' book.pk %}">Edit</a>
{% endif %}
```

## Testing the Implementation

### Creating Test Users
1. Create users via Django Admin or shell
2. Assign them to different groups
3. Test access by logging in as each user

### Test Scenarios
1. **Viewer User**: Should only see view buttons/links
2. **Editor User**: Should see view, create, edit buttons (no delete)
3. **Admin User**: Should see all buttons including delete

### Example Test Commands
```python
# Create test users
from django.contrib.auth.models import Group
from bookshelf.models import CustomUser

# Create a viewer
viewer = CustomUser.objects.create_user('viewer_user', 'viewer@example.com', 'password')
viewers_group = Group.objects.get(name='Viewers')
viewer.groups.add(viewers_group)

# Create an editor
editor = CustomUser.objects.create_user('editor_user', 'editor@example.com', 'password')
editors_group = Group.objects.get(name='Editors')
editor.groups.add(editors_group)

# Create an admin
admin_user = CustomUser.objects.create_user('admin_user', 'admin@example.com', 'password')
admins_group = Group.objects.get(name='Admins')
admin_user.groups.add(admins_group)
```

## URL Patterns
- `/books/` - List all books (requires can_view)
- `/books/create/` - Create new book (requires can_create)
- `/books/<id>/edit/` - Edit book (requires can_edit)
- `/books/<id>/delete/` - Delete book (requires can_delete)
- `/books/<id>/` - View book details (requires can_view)

## Security Notes
- All views are protected by appropriate permissions
- Users without permissions get a 403 Forbidden error
- Templates hide action buttons based on user permissions
- The `raise_exception=True` parameter ensures proper error handling
- Always use HTTPS in production for secure authentication

## Troubleshooting
- If permissions aren't working, check that migrations have been run
- Ensure users are properly assigned to groups
- Verify that the custom permissions exist in the database
- Check that AUTH_USER_MODEL is properly configured if using CustomUser
EOF

echo "✅ Created permissions setup documentation"

# 9. Update settings.py to include proper configuration
echo "📝 Step 9: Updating Django settings..."

# Create a backup of settings.py and update it
cp "$BASE_DIR/LibraryProject/settings.py" "$BASE_DIR/LibraryProject/settings.py.backup" 2>/dev/null || true

cat >> "$BASE_DIR/LibraryProject/settings.py" << 'EOF'

# Media files configuration
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Custom user model (if using CustomUser)
# AUTH_USER_MODEL = 'bookshelf.CustomUser'

# Login URLs
LOGIN_URL = '/admin/login/'
LOGIN_REDIRECT_URL = '/books/'
LOGOUT_REDIRECT_URL = '/books/'
EOF

echo "✅ Updated Django settings"

# 10. Create a test script
echo "📝 Step 10: Creating test script..."

cat > "$BASE_DIR/test_permissions.py" << 'EOF'
#!/usr/bin/env python
"""
Test script for permissions system
Run this script to create test users and verify permissions
"""
import os
import sys
import django

# Setup Django environment
sys.path.insert(0, '/home/mhmd/study/alx/Alx_DjangoLearnLab/advanced_features_and_security/LibraryProject')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'LibraryProject.settings')
django.setup()

from django.contrib.auth.models import Group, User
from bookshelf.models import CustomUser, Book, Library

def create_test_users():
    """Create test users for different groups"""
    print("Creating test users...")
    
    # Get or create groups
    viewers_group, _ = Group.objects.get_or_create(name='Viewers')
    editors_group, _ = Group.objects.get_or_create(name='Editors')
    admins_group, _ = Group.objects.get_or_create(name='Admins')
    
    # Create test users
    users_data = [
        ('viewer_test', 'viewer@test.com', 'viewers123', viewers_group),
        ('editor_test', 'editor@test.com', 'editors123', editors_group),
        ('admin_test', 'admin@test.com', 'admins123', admins_group),
    ]
    
    for username, email, password, group in users_data:
        try:
            if hasattr(django.contrib.auth, 'get_user_model'):
                User = django.contrib.auth.get_user_model()
            else:
                from django.contrib.auth.models import User
                
            user, created = User.objects.get_or_create(
                username=username,
                defaults={'email': email}
            )
            if created:
                user.set_password(password)
                user.save()
                user.groups.add(group)
                print(f"✅ Created user: {username} (Group: {group.name})")
            else:
                print(f"👤 User {username} already exists")
        except Exception as e:
            print(f"❌ Error creating user {username}: {e}")

def create_test_books():
    """Create some test books"""
    print("Creating test books...")
    
    books_data = [
        ("The Django Book", "Adrian Holovaty", 2023, "978-0123456789"),
        ("Python Programming", "John Smith", 2022, "978-0987654321"),
        ("Web Development Guide", "Jane Doe", 2024, "978-0456789123"),
    ]
    
    for title, author, year, isbn in books_data:
        book, created = Book.objects.get_or_create(
            isbn=isbn,
            defaults={
                'title': title,
                'author': author,
                'publication_year': year,
                'pages': 200
            }
        )
        if created:
            print(f"📚 Created book: {title}")
        else:
            print(f"📖 Book {title} already exists")

def display_test_info():
    """Display information about test users and login instructions"""
    print("\n" + "="*50)
    print("PERMISSIONS TESTING SETUP COMPLETE")
    print("="*50)
    print("\nTest Users Created:")
    print("1. Username: viewer_test, Password: viewers123 (Viewers Group)")
    print("2. Username: editor_test, Password: editors123 (Editors Group)")  
    print("3. Username: admin_test, Password: admins123 (Admins Group)")
    
    print("\nTo test permissions:")
    print("1. Run migrations: python manage.py makemigrations && python manage.py migrate")
    print("2. Setup groups: python manage.py setup_groups")
    print("3. Start server: python manage.py runserver")
    print("4. Visit: http://127.0.0.1:8000/books/")
    print("5. Login with different users to test permissions")
    
    print("\nExpected Behavior:")
    print("- viewer_test: Can only view books")
    print("- editor_test: Can view, create, edit books")
    print("- admin_test: Can view, create, edit, delete books")

if __name__ == "__main__":
    create_test_users()
    create_test_books()
    display_test_info()
EOF

chmod +x "$BASE_DIR/test_permissions.py"

echo "✅ Created test script"

# 11. Create migration files hint
echo "📝 Step 11: Creating migration instructions..."

cat > "$BASE_DIR/MIGRATION_COMMANDS.txt" << 'EOF'
# Commands to run after setting up the permissions system:

# 1. Create and apply migrations
cd /home/mhmd/study/alx/Alx_DjangoLearnLab/advanced_features_and_security/LibraryProject
python manage.py makemigrations bookshelf
python manage.py migrate

# 2. Setup groups and permissions
python manage.py setup_groups

# 3. Create a superuser (optional)
python manage.py createsuperuser

# 4. Run the test script to create test users
python test_permissions.py

# 5. Start the development server
python manage.py runserver

# 6. Test the application
# Visit: http://127.0.0.1:8000/admin/ to manage users and groups
# Visit: http://127.0.0.1:8000/books/ to test the permissions
EOF

echo "✅ Created migration instructions"

# 12. Create a quick setup script
echo "📝 Step 12: Creating quick setup script..."

cat > "$BASE_DIR/quick_setup.sh" << 'EOF'
#!/bin/bash

echo "🚀 Quick Setup for Permissions System"
echo "====================================="

cd /home/mhmd/study/alx/Alx_DjangoLearnLab/advanced_features_and_security/LibraryProject

echo "📝 Making migrations..."
python manage.py makemigrations bookshelf

echo "🔄 Applying migrations..."
python manage.py migrate

echo "👥 Setting up groups and permissions..."
python manage.py setup_groups

echo "🧪 Creating test users and books..."
python test_permissions.py

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Run: python manage.py runserver"
echo "2. Visit: http://127.0.0.1:8000/books/"
echo "3. Test with different users:"
echo "   - viewer_test / viewers123"
echo "   - editor_test / editors123" 
echo "   - admin_test / admins123"
EOF

chmod +x "$BASE_DIR/quick_setup.sh"

echo "✅ Created quick setup script"

# Final summary
echo ""
echo "🎉 DJANGO PERMISSIONS SYSTEM SETUP COMPLETE!"
echo "============================================="
echo ""
echo "📁 Files created/updated:"
echo "  ✅ bookshelf/models.py - Updated with custom permissions"
echo "  ✅ bookshelf/views.py - Created permission-protected views"
echo "  ✅ bookshelf/forms.py - Created forms for book management"
echo "  ✅ bookshelf/urls.py - Created URL patterns"
echo "  ✅ LibraryProject/urls.py - Updated main URLs"
echo "  ✅ Templates - Created all necessary HTML templates"
echo "  ✅ Management command - setup_groups.py"
echo "  ✅ Documentation - PERMISSIONS_SETUP.md"
echo "  ✅ Test script - test_permissions.py"
echo "  ✅ Quick setup - quick_setup.sh"
echo ""
echo "🚀 To get started:"
echo "  1. cd $BASE_DIR"
echo "  2. ./quick_setup.sh"
echo "  3. python manage.py runserver"
echo ""
echo "📚 Three user groups created:"
echo "  👀 Viewers - Can view books only"
echo "  ✏️  Editors - Can view, create, edit books"
echo "  🔐 Admins - Full access (including delete)"
echo ""
echo "🧪 Test users will be created:"
echo "  📖 viewer_test / viewers123"
echo "  ✏️  editor_test / editors123"
echo "  🔐 admin_test / admins123"
echo ""
echo "📖 Read PERMISSIONS_SETUP.md for detailed documentation!"

exit 0
