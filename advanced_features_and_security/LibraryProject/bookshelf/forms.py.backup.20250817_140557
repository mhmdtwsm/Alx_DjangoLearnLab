from django import forms
from .models import Book, Library

class BookForm(forms.ModelForm):
    class Meta:
        model = Book
        fields = ['title', 'author', 'publication_year', 'isbn', 'pages', 'cover', 'language']
        widgets = {
            'title': forms.TextInput(attrs={'class': 'form-control'}),
            'author': forms.TextInput(attrs={'class': 'form-control'}),
            'publication_year': forms.NumberInput(attrs={'class': 'form-control'}),
            'isbn': forms.TextInput(attrs={'class': 'form-control'}),
            'pages': forms.NumberInput(attrs={'class': 'form-control'}),
            'cover': forms.FileInput(attrs={'class': 'form-control'}),
            'language': forms.TextInput(attrs={'class': 'form-control'}),
        }

class LibraryForm(forms.ModelForm):
    class Meta:
        model = Library
        fields = ['name', 'books']
        widgets = {
            'name': forms.TextInput(attrs={'class': 'form-control'}),
            'books': forms.CheckboxSelectMultiple(),
        }
