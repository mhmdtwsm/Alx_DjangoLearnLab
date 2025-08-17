from django.shortcuts import render, get_object_or_404, redirect
from django.views.generic import ListView, DetailView
from .models import Library
from .models import Book, UserProfile  # Import new models
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django.contrib.auth import login, logout, authenticate
from django.contrib import messages
from django.contrib.auth.decorators import (
    login_required,
    user_passes_test,
    permission_required,
)
from django.urls import reverse_lazy  # For class-based view redirects

# Task 1: Function-based View to list all books


def list_books(request):
    books = Book.objects.all()
    return render(request, "relationship_app/list_books.html", {"books": books})


# Task 1: Class-based View to display library details


class LibraryDetailView(DetailView):
    model = Library
    template_name = "relationship_app/library_detail.html"
    context_object_name = "library"


# Task 2: User Registration View


def register_view(request):
    if request.method == "POST":
        form = UserCreationForm(request.POST)
        if form.is_valid():
            user = form.save()
            # Automatically create UserProfile via signal
            messages.success(request, "Registration successful! You can now log in.")
            return redirect("login")
        else:
            messages.error(request, "Registration failed. Please correct the errors.")
    else:
        form = UserCreationForm()
    return render(request, "relationship_app/register.html", {"form": form})


# Task 2: User Login View


def login_view(request):
    if request.method == "POST":
        form = AuthenticationForm(request, data=request.POST)
        if form.is_valid():
            username = form.cleaned_data.get("username")
            password = form.cleaned_data.get("password")
            user = authenticate(username=username, password=password)
            if user is not None:
                login(request, user)
                messages.info(request, f"You are now logged in as {username}.")
                return redirect("home")  # Redirect to a home page after login
            else:
                messages.error(request, "Invalid username or password.")
        else:
            messages.error(request, "Invalid username or password.")
    else:
        form = AuthenticationForm()
    return render(request, "relationship_app/login.html", {"form": form})


# Task 2: User Logout View


@login_required
def logout_view(request):
    logout(request)
    messages.info(request, "You have been logged out.")
    return redirect("login")


# Helper function to check user roles


def is_admin(user):
    return (
        user.is_authenticated
        and hasattr(user, "userprofile")
        and user.userprofile.role == "Admin"
    )


def is_librarian(user):
    return (
        user.is_authenticated
        and hasattr(user, "userprofile")
        and user.userprofile.role == "Librarian"
    )


def is_member(user):
    return (
        user.is_authenticated
        and hasattr(user, "userprofile")
        and user.userprofile.role == "Member"
    )


# Task 3: Role-Based Views


@user_passes_test(is_admin, login_url="/login/")
@login_required(login_url="/login/")
def admin_view(request):
    return render(request, "relationship_app/admin_view.html")


@user_passes_test(is_librarian, login_url="/login/")
@login_required(login_url="/login/")
def librarian_view(request):
    return render(request, "relationship_app/librarian_view.html")


@user_passes_test(is_member, login_url="/login/")
@login_required(login_url="/login/")
def member_view(request):
    return render(request, "relationship_app/member_view.html")


# Task 4: Views for Book Operations with Custom Permissions
# Placeholder for book creation view


@permission_required("relationship_app.can_add_book", login_url="/login/")
@login_required(login_url="/login/")
def add_book_view(request):
    # This would typically involve a form to add a book
    # Need to create this template
    return render(request, "relationship_app/add_book.html")


# Placeholder for book editing view


@permission_required("relationship_app.can_change_book", login_url="/login/")
@login_required(login_url="/login/")
def edit_book_view(request, pk):
    book = get_object_or_404(Book, pk=pk)
    # This would typically involve a form to edit a book
    # Need to create this template
    return render(request, "relationship_app/edit_book.html", {"book": book})


# Placeholder for book deletion view


@permission_required("relationship_app.can_delete_book", login_url="/login/")
@login_required(login_url="/login/")
def delete_book_view(request, pk):
    book = get_object_or_404(Book, pk=pk)
    # This would typically involve a confirmation for deletion
    if request.method == "POST":
        book.delete()
        messages.success(request, "Book deleted successfully.")
        return redirect("list_books")
    # Need to create this template
    return render(request, "relationship_app/delete_book_confirm.html", {"book": book})
