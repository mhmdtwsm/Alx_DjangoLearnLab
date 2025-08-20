from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from .models import Comment


class UserRegisterForm(UserCreationForm):
    email = forms.EmailField(required=True)

    class Meta:
        model = User
        fields = ["username", "email", "password1", "password2"]


class CommentForm(forms.ModelForm):
    content = forms.CharField(widget=forms.Textarea, max_length=500)

    class Meta:
        model = Comment
        fields = ["content"]
