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
    content = forms.CharField(
        widget=forms.Textarea(attrs={"rows": 3, "placeholder": "Add a comment..."}),
        max_length=500,
        required=True,
        help_text="Comments cannot exceed 500 characters.",
    )

    class Meta:
        model = Comment
        fields = ["content"]

    def clean_content(self):
        content = self.cleaned_data.get("content")
        if len(content.strip()) == 0:
            raise forms.ValidationError("Comment cannot be empty or just spaces.")
        return content
