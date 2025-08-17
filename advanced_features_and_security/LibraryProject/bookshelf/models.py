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
