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
