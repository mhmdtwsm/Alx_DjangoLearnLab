import os
import django

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'django-models.settings')
django.setup()

from relationship_app.models import Author, Book, Library, Librarian, User, UserProfile

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
