from django import forms
from django.core.exceptions import ValidationError
from django.utils.html import escape
import re

class BookSearchForm(forms.Form):
    """
    Secure form for book search functionality.
    Implements input validation and sanitization to prevent XSS and injection attacks.
    """
    query = forms.CharField(
        max_length=200,
        required=True,
        widget=forms.TextInput(attrs={
            'placeholder': 'Search for books...',
            'class': 'form-control',
        })
    )
    
    def clean_query(self):
        """
        Validate and sanitize search query input.
        Prevents malicious input and potential XSS attacks.
        """
        query = self.cleaned_data.get('query')
        if query:
            # Remove potentially dangerous characters
            query = escape(query.strip())
            
            # Basic validation - only allow alphanumeric, spaces, and basic punctuation
            if not re.match(r'^[a-zA-Z0-9\s\-\.\,\'\"]+$', query):
                raise ValidationError("Search query contains invalid characters.")
                
            # Prevent very long queries that could cause issues
            if len(query) > 200:
                raise ValidationError("Search query is too long.")
                
        return query


class SecureBookForm(forms.Form):
    """
    Secure form for book-related operations.
    Implements comprehensive input validation and CSRF protection.
    """
    title = forms.CharField(
        max_length=200,
        required=True,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'Enter book title'
        })
    )
    
    author = forms.CharField(
        max_length=100,
        required=True,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'Enter author name'
        })
    )
    
    publication_year = forms.IntegerField(
        required=True,
        min_value=1000,
        max_value=2024,
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'placeholder': 'Enter publication year'
        })
    )
    
    def clean_title(self):
        """Validate and sanitize book title."""
        title = self.cleaned_data.get('title')
        if title:
            title = escape(title.strip())
            if len(title) < 2:
                raise ValidationError("Title must be at least 2 characters long.")
        return title
    
    def clean_author(self):
        """Validate and sanitize author name."""
        author = self.cleaned_data.get('author')
        if author:
            author = escape(author.strip())
            if not re.match(r'^[a-zA-Z\s\.\-\']+$', author):
                raise ValidationError("Author name contains invalid characters.")
        return author


class SecureCommentForm(forms.Form):
    """
    Secure form for user comments with XSS protection.
    """
    comment = forms.CharField(
        widget=forms.Textarea(attrs={
            'class': 'form-control',
            'rows': 4,
            'placeholder': 'Enter your comment...'
        }),
        max_length=1000,
        required=True
    )
    
    def clean_comment(self):
        """Validate and sanitize comment input to prevent XSS."""
        comment = self.cleaned_data.get('comment')
        if comment:
            # Escape HTML to prevent XSS
            comment = escape(comment.strip())
            
            # Check for minimum length
            if len(comment) < 5:
                raise ValidationError("Comment must be at least 5 characters long.")
                
        return comment
