from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from taggit.forms import TagWidget  # ✅ import TagWidget
from .models import Comment, Post  # ✅ import Post model


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


# ✅ PostForm with TagWidget
class PostForm(forms.ModelForm):
    class Meta:
        model = Post
        fields = ["title", "content", "tags"]  # include tags field
        widgets = {
            "tags": TagWidget(),  # use TagWidget for better UI
        }
