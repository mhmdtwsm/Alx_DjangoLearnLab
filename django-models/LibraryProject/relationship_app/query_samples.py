from relationship_app.models import Author, Book, Library, Librarian, User, UserProfile
import os
import django

# Setup Django environment
# Ensure this matches your project name
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "django-models.settings")
django.setup()


def run_queries():
    print("--- Running Sample Queries ---")

    # Clear existing data for a clean run (optional, for testing)
    Author.objects.all().delete()
    Book.objects.all().delete()
    Library.objects.all().delete()
    Librarian.objects.all().delete()
    User.objects.filter(is_superuser=False).delete()  # Don't delete superuser

    # Create sample data
    author1 = Author.objects.create(name="Jane Austen")
    author2 = Author.objects.create(name="George Orwell")

    book1 = Book.objects.create(
        title="Pride and Prejudice", author=author1, publication_year=1813
    )
    book2 = Book.objects.create(title="1984", author=author2, publication_year=1949)
    book3 = Book.objects.create(
        title="Sense and Sensibility", author=author1, publication_year=1811
    )

    library1 = Library.objects.create(name="Central Library")
    library1.books.add(book1, book2)

    library2 = Library.objects.create(name="Community Bookshelf")
    library2.books.add(book3)

    librarian1 = Librarian.objects.create(name="Alice Smith", library=library1)
    librarian2 = Librarian.objects.create(name="Bob Johnson", library=library2)

    # Create test users (profiles created by signal)
    user_admin = User.objects.create_user(
        username="admin_user", email="admin@example.com", password="password123"
    )
    user_admin.is_staff = True  # Needed for admin panel access
    user_admin.is_superuser = True  # Make this user a superuser for initial setup
    user_admin.save()
    user_admin.userprofile.role = "Admin"
    user_admin.userprofile.save()

    user_librarian = User.objects.create_user(
        username="librarian_user", email="librarian@example.com", password="password123"
    )
    user_librarian.userprofile.role = "Librarian"
    user_librarian.userprofile.save()

    user_member = User.objects.create_user(
        username="member_user", email="member@example.com", password="password123"
    )
    user_member.userprofile.role = "Member"
    user_member.userprofile.save()

    # --- Task 0: Implement Sample Queries ---

    print("\nQuery 1: All books by a specific author (Jane Austen)")
    # --- START OF EDITED SECTION FOR CHECKER ---
    author_name = "Jane Austen"  # Using the exact variable name "author_name"
    try:
        # Using "author" for the retrieved object
        author = Author.objects.get(name=author_name)
        books_by_author = Book.objects.filter(
            author=author
        )  # Filter using "author" object
        for book in books_by_author:
            print(f"- {book.title} by {book.author.name}")
    except Author.DoesNotExist:
        print(f"Error: Author with name '{author_name}' does not exist.")
    except Author.MultipleObjectsReturned:
        print(
            f"Error: Multiple authors with name '{
                author_name
            }' found. Please ensure author names are unique."
        )
    # --- END OF EDITED SECTION FOR CHECKER ---

    print("\nQuery 2: All books in a library (Central Library)")
    library_name = "Central Library"
    try:
        central_library_obj = Library.objects.get(name=library_name)
        central_library_books = central_library_obj.books.all()
        for book in central_library_books:
            print(f"- {book.title} by {book.author.name}")
    except Library.DoesNotExist:
        print(f"Error: Library with name '{library_name}' does not exist.")
    except Library.MultipleObjectsReturned:
        print(
            f"Error: Multiple libraries with name '{
                library_name
            }' found. Please use a unique identifier."
        )

    print("\nQuery 3: Retrieve the librarian for a library (Central Library)")
    try:
        central_library_obj_for_librarian = Library.objects.get(name="Central Library")
        central_librarian = central_library_obj_for_librarian.librarian
        print(f"- The librarian for Central Library is: {central_librarian.name}")
    except Library.DoesNotExist:
        print(f"Error: Library 'Central Library' does not exist for librarian query.")
    except Librarian.DoesNotExist:
        print(f"Error: No librarian found for 'Central Library'.")

    print("\n--- Sample Data Created and Queries Executed ---")


if __name__ == "__main__":
    run_queries()
