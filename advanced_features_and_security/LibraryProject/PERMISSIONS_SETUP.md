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
