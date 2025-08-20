from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token
from api.models import Book

class Command(BaseCommand):
    help = 'Create test data for the API'

    def handle(self, *args, **options):
        # Create test users
        if not User.objects.filter(username='testuser').exists():
            user = User.objects.create_user(
                username='testuser',
                email='test@example.com',
                password='testpass123'
            )
            Token.objects.create(user=user)
            self.stdout.write(
                self.style.SUCCESS(f'Created test user: testuser (token: {user.auth_token.key})')
            )
        
        # Create test books
        test_books = [
            {'title': 'Django for Beginners', 'author': 'William Vincent'},
            {'title': 'Two Scoops of Django', 'author': 'Daniel Roy Greenfeld'},
            {'title': 'Django REST Framework Tutorial', 'author': 'John Doe'},
            {'title': 'Python Crash Course', 'author': 'Eric Matthes'},
            {'title': 'Automate the Boring Stuff', 'author': 'Al Sweigart'},
        ]
        
        for book_data in test_books:
            book, created = Book.objects.get_or_create(**book_data)
            if created:
                self.stdout.write(
                    self.style.SUCCESS(f'Created book: {book.title}')
                )
        
        self.stdout.write(
            self.style.SUCCESS('Test data creation completed!')
        )
