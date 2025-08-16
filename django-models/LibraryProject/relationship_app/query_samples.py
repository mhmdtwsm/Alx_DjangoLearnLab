from django.core.exceptions import ObjectDoesNotExist
from .models import Library, Librarian, Book, Author


# 1. Get a Library by name
def get_library_by_name(library_name):
    try:
        return Library.objects.get(name=library_name)
    except ObjectDoesNotExist:
        return None


# 2. Get all books written by a given author
def get_books_by_author(author_name):
    return Book.objects.filter(author__name=author_name)


# 3. Get the librarian of a given library
def get_librarian_by_library(library_name):
    try:
        library = Library.objects.get(name=library_name)
        return library.librarian  # reverse OneToOne relationship
    except ObjectDoesNotExist:
        return None


# 4. Get all libraries where a given book is available
def get_libraries_by_book(book_title):
    return Library.objects.filter(books__title=book_title)


# 5. Get all authors that have books in a given library
def get_authors_by_library(library_name):
    return Author.objects.filter(books__libraries__name=library_name).distinct()
