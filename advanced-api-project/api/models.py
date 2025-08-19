"""
Models for the Advanced API Project

This module defines the core data models for our book management system.
It demonstrates Django's ORM capabilities and establishes relationships
between Authors and Books using foreign keys.

Models:
- Author: Represents book authors with basic information
- Book: Represents books with publication details and author relationships
"""

from django.db import models
from django.core.validators import MaxValueValidator
from datetime import datetime


class Author(models.Model):
    """
    Author model representing book authors.
    
    This model stores basic information about authors and establishes
    a one-to-many relationship with books (one author can write many books).
    
    Fields:
        name (CharField): The full name of the author
    
    Methods:
        __str__: Returns the author's name for string representation
    """
    
    name = models.CharField(
        max_length=100,
        help_text="The full name of the author"
    )
    
    class Meta:
        ordering = ['name']  # Order authors alphabetically by name
        verbose_name = "Author"
        verbose_name_plural = "Authors"
    
    def __str__(self):
        """Return string representation of the author."""
        return self.name


class Book(models.Model):
    """
    Book model representing individual books in our system.
    
    This model stores book information and establishes a foreign key
    relationship with the Author model, allowing for one-to-many
    relationships (one author can have multiple books).
    
    Fields:
        title (CharField): The title of the book
        publication_year (IntegerField): The year the book was published
        author (ForeignKey): Reference to the Author who wrote this book
    
    Relationships:
        author: Many-to-One relationship with Author model
    
    Methods:
        __str__: Returns the book title for string representation
    """
    
    title = models.CharField(
        max_length=200,
        help_text="The title of the book"
    )
    
    publication_year = models.IntegerField(
        validators=[MaxValueValidator(datetime.now().year)],
        help_text="The year the book was published (cannot be in the future)"
    )
    
    author = models.ForeignKey(
        Author,
        on_delete=models.CASCADE,
        related_name='books',
        help_text="The author who wrote this book"
    )
    
    class Meta:
        ordering = ['-publication_year', 'title']  # Order by year (newest first), then title
        verbose_name = "Book"
        verbose_name_plural = "Books"
        # Ensure no duplicate books by the same author with the same title and year
        unique_together = ['title', 'author', 'publication_year']
    
    def __str__(self):
        """Return string representation of the book."""
        return f"{self.title} ({self.publication_year})"
