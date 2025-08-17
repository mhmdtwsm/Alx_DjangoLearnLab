from django import forms
from django.core.exceptions import ValidationError
from django.utils.html import escape
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
import re


class ExampleForm(forms.Form):
    """
    Example form demonstrating secure Django form practices.
    Implements CSRF protection, input validation, and XSS prevention.
    """

    name = forms.CharField(
        max_length=100,
        required=True,
        widget=forms.TextInput(
            attrs={
                "class": "form-control",
                "placeholder": "Enter your name",
                "autocomplete": "name",
            }
        ),
        help_text="Enter your full name (letters, spaces, hyphens, and apostrophes only)",
    )

    email = forms.EmailField(
        required=True,
        widget=forms.EmailInput(
            attrs={
                "class": "form-control",
                "placeholder": "Enter your email address",
                "autocomplete": "email",
            }
        ),
        help_text="Enter a valid email address",
    )

    age = forms.IntegerField(
        required=False,
        min_value=13,
        max_value=120,
        widget=forms.NumberInput(
            attrs={"class": "form-control", "placeholder": "Enter your age"}
        ),
        help_text="Age must be between 13 and 120",
    )

    message = forms.CharField(
        widget=forms.Textarea(
            attrs={
                "class": "form-control",
                "rows": 4,
                "placeholder": "Enter your message...",
                "maxlength": "500",
            }
        ),
        max_length=500,
        required=True,
        help_text="Enter a message (maximum 500 characters)",
    )

    newsletter = forms.BooleanField(
        required=False,
        widget=forms.CheckboxInput(attrs={"class": "form-check-input"}),
        help_text="Check to subscribe to our newsletter",
    )

    category = forms.ChoiceField(
        choices=[
            ("", "Select a category"),
            ("general", "General Inquiry"),
            ("support", "Technical Support"),
            ("feedback", "Feedback"),
            ("other", "Other"),
        ],
        required=True,
        widget=forms.Select(attrs={"class": "form-control"}),
        help_text="Select the category that best describes your inquiry",
    )

    def clean_name(self):
        """Validate and sanitize name field."""
        name = self.cleaned_data.get("name")
        if name:
            name = escape(name.strip())
            # Allow letters, spaces, hyphens, and apostrophes
            if not re.match(r"^[a-zA-Z\s\-\'\.]+$", name):
                raise ValidationError(
                    "Name can only contain letters, spaces, hyphens, and apostrophes."
                )

            if len(name) < 2:
                raise ValidationError("Name must be at least 2 characters long.")
        return name

    def clean_message(self):
        """Validate and sanitize message field."""
        message = self.cleaned_data.get("message")
        if message:
            message = escape(message.strip())

            if len(message) < 10:
                raise ValidationError("Message must be at least 10 characters long.")

            # Check for spam-like patterns
            spam_patterns = [
                r"http[s]?://",  # URLs
                r"www\.",  # Web addresses
                r"click here",  # Spam phrases
                r"buy now",
                r"free money",
            ]

            for pattern in spam_patterns:
                if re.search(pattern, message, re.IGNORECASE):
                    raise ValidationError("Message contains prohibited content.")

        return message

    def clean(self):
        """Additional form-wide validation."""
        cleaned_data = super().clean()
        name = cleaned_data.get("name")
        email = cleaned_data.get("email")

        # Cross-field validation example
        if name and email:
            # Ensure name and email don't match (basic spam check)
            if name.lower().replace(" ", "") == email.split("@")[0].lower():
                raise ValidationError("Name and email appear to be invalid.")

        return cleaned_data


class BookSearchForm(forms.Form):
    """
    Secure form for book search functionality.
    Implements input validation and sanitization to prevent XSS and injection attacks.
    """

    query = forms.CharField(
        max_length=200,
        required=True,
        widget=forms.TextInput(
            attrs={
                "placeholder": "Search for books...",
                "class": "form-control",
                "autocomplete": "off",
            }
        ),
        help_text="Enter keywords to search for books",
    )

    search_type = forms.ChoiceField(
        choices=[
            ("all", "All Fields"),
            ("title", "Title Only"),
            ("author", "Author Only"),
            ("isbn", "ISBN Only"),
        ],
        required=False,
        initial="all",
        widget=forms.Select(attrs={"class": "form-control"}),
        help_text="Choose what to search in",
    )

    def clean_query(self):
        """
        Validate and sanitize search query input.
        Prevents malicious input and potential XSS attacks.
        """
        query = self.cleaned_data.get("query")
        if query:
            # Remove potentially dangerous characters
            query = escape(query.strip())

            # Basic validation - only allow alphanumeric, spaces, and basic punctuation
            if not re.match(r"^[a-zA-Z0-9\s\-\.\,\'\"\(\)]+$", query):
                raise ValidationError("Search query contains invalid characters.")

            # Prevent very long queries that could cause issues
            if len(query) > 200:
                raise ValidationError("Search query is too long.")

            # Minimum length check
            if len(query) < 2:
                raise ValidationError(
                    "Search query must be at least 2 characters long."
                )

        return query


class SecureBookForm(forms.Form):
    """
    Secure form for book-related operations.
    Implements comprehensive input validation and CSRF protection.
    """

    title = forms.CharField(
        max_length=200,
        required=True,
        widget=forms.TextInput(
            attrs={
                "class": "form-control",
                "placeholder": "Enter book title",
                "autocomplete": "off",
            }
        ),
        help_text="Enter the complete book title",
    )

    author = forms.CharField(
        max_length=100,
        required=True,
        widget=forms.TextInput(
            attrs={
                "class": "form-control",
                "placeholder": "Enter author name",
                "autocomplete": "off",
            }
        ),
        help_text="Enter the author's full name",
    )

    publication_year = forms.IntegerField(
        required=True,
        min_value=1000,
        max_value=2025,  # Updated to current year + 1
        widget=forms.NumberInput(
            attrs={
                "class": "form-control",
                "placeholder": "Enter publication year",
                "min": "1000",
                "max": "2025",
            }
        ),
        help_text="Enter a year between 1000 and 2025",
    )

    isbn = forms.CharField(
        max_length=17,  # ISBN-13 with hyphens
        required=False,
        widget=forms.TextInput(
            attrs={
                "class": "form-control",
                "placeholder": "Enter ISBN (optional)",
                "pattern": r"[\d\-X]+",
                "title": "Enter a valid ISBN",
            }
        ),
        help_text="Enter ISBN-10 or ISBN-13 (optional)",
    )

    description = forms.CharField(
        widget=forms.Textarea(
            attrs={
                "class": "form-control",
                "rows": 3,
                "placeholder": "Enter book description (optional)",
                "maxlength": "1000",
            }
        ),
        max_length=1000,
        required=False,
        help_text="Brief description of the book (maximum 1000 characters)",
    )

    def clean_title(self):
        """Validate and sanitize book title."""
        title = self.cleaned_data.get("title")
        if title:
            title = escape(title.strip())
            if len(title) < 2:
                raise ValidationError("Title must be at least 2 characters long.")

            # Check for reasonable title length
            if len(title) > 200:
                raise ValidationError("Title is too long (maximum 200 characters).")
        return title

    def clean_author(self):
        """Validate and sanitize author name."""
        author = self.cleaned_data.get("author")
        if author:
            author = escape(author.strip())
            # Allow letters, spaces, periods, hyphens, apostrophes
            if not re.match(r"^[a-zA-Z\s\.\-\',]+$", author):
                raise ValidationError("Author name contains invalid characters.")

            if len(author) < 2:
                raise ValidationError("Author name must be at least 2 characters long.")
        return author

    def clean_isbn(self):
        """Validate ISBN format."""
        isbn = self.cleaned_data.get("isbn")
        if isbn:
            # Remove spaces and hyphens for validation
            isbn_clean = re.sub(r"[\s\-]", "", isbn)

            # Check if it's a valid ISBN format (10 or 13 digits, possibly with X)
            if not re.match(r"^(\d{9}[\dX]|\d{13})$", isbn_clean):
                raise ValidationError("Please enter a valid ISBN-10 or ISBN-13.")

            return isbn.strip()
        return isbn

    def clean_description(self):
        """Validate and sanitize description."""
        description = self.cleaned_data.get("description")
        if description:
            description = escape(description.strip())

            if len(description) > 1000:
                raise ValidationError(
                    "Description is too long (maximum 1000 characters)."
                )

        return description


class SecureCommentForm(forms.Form):
    """
    Secure form for user comments with XSS protection.
    """

    name = forms.CharField(
        max_length=100,
        required=True,
        widget=forms.TextInput(
            attrs={
                "class": "form-control",
                "placeholder": "Enter your name",
                "autocomplete": "name",
            }
        ),
        help_text="Enter your name",
    )

    email = forms.EmailField(
        required=False,
        widget=forms.EmailInput(
            attrs={
                "class": "form-control",
                "placeholder": "Enter your email (optional)",
                "autocomplete": "email",
            }
        ),
        help_text="Your email won't be published (optional)",
    )

    comment = forms.CharField(
        widget=forms.Textarea(
            attrs={
                "class": "form-control",
                "rows": 4,
                "placeholder": "Enter your comment...",
                "maxlength": "1000",
            }
        ),
        max_length=1000,
        required=True,
        help_text="Share your thoughts (maximum 1000 characters)",
    )

    rating = forms.ChoiceField(
        choices=[
            ("", "No rating"),
            ("1", "1 Star"),
            ("2", "2 Stars"),
            ("3", "3 Stars"),
            ("4", "4 Stars"),
            ("5", "5 Stars"),
        ],
        required=False,
        widget=forms.Select(attrs={"class": "form-control"}),
        help_text="Rate this book (optional)",
    )

    def clean_name(self):
        """Validate and sanitize commenter name."""
        name = self.cleaned_data.get("name")
        if name:
            name = escape(name.strip())
            if not re.match(r"^[a-zA-Z\s\.\-\']+$", name):
                raise ValidationError("Name contains invalid characters.")

            if len(name) < 2:
                raise ValidationError("Name must be at least 2 characters long.")
        return name

    def clean_comment(self):
        """Validate and sanitize comment input to prevent XSS."""
        comment = self.cleaned_data.get("comment")
        if comment:
            # Escape HTML to prevent XSS
            comment = escape(comment.strip())

            # Check for minimum length
            if len(comment) < 5:
                raise ValidationError("Comment must be at least 5 characters long.")

            # Check for spam patterns
            spam_indicators = ["http://", "https://", "www.", "click here", "buy now"]
            comment_lower = comment.lower()

            for indicator in spam_indicators:
                if indicator in comment_lower:
                    raise ValidationError(
                        "Comments cannot contain URLs or promotional content."
                    )

        return comment


class SecureUserRegistrationForm(UserCreationForm):
    """
    Secure user registration form with additional validation.
    Extends Django's built-in UserCreationForm with security enhancements.
    """

    email = forms.EmailField(
        required=True,
        widget=forms.EmailInput(
            attrs={
                "class": "form-control",
                "placeholder": "Enter your email address",
                "autocomplete": "email",
            }
        ),
        help_text="Enter a valid email address",
    )

    first_name = forms.CharField(
        max_length=30,
        required=True,
        widget=forms.TextInput(
            attrs={
                "class": "form-control",
                "placeholder": "Enter your first name",
                "autocomplete": "given-name",
            }
        ),
        help_text="Enter your first name",
    )

    last_name = forms.CharField(
        max_length=30,
        required=True,
        widget=forms.TextInput(
            attrs={
                "class": "form-control",
                "placeholder": "Enter your last name",
                "autocomplete": "family-name",
            }
        ),
        help_text="Enter your last name",
    )

    terms_accepted = forms.BooleanField(
        required=True,
        widget=forms.CheckboxInput(attrs={"class": "form-check-input"}),
        help_text="You must accept the terms and conditions to register",
    )

    class Meta:
        model = User
        fields = (
            "username",
            "first_name",
            "last_name",
            "email",
            "password1",
            "password2",
        )
        widgets = {
            "username": forms.TextInput(
                attrs={
                    "class": "form-control",
                    "placeholder": "Choose a username",
                    "autocomplete": "username",
                }
            ),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Add Bootstrap classes to password fields
        self.fields["password1"].widget.attrs.update(
            {
                "class": "form-control",
                "placeholder": "Enter password",
                "autocomplete": "new-password",
            }
        )
        self.fields["password2"].widget.attrs.update(
            {
                "class": "form-control",
                "placeholder": "Confirm password",
                "autocomplete": "new-password",
            }
        )

    def clean_email(self):
        """Validate email uniqueness."""
        email = self.cleaned_data.get("email")
        if email and User.objects.filter(email=email).exists():
            raise ValidationError("A user with this email address already exists.")
        return email

    def clean_first_name(self):
        """Validate first name."""
        first_name = self.cleaned_data.get("first_name")
        if first_name:
            first_name = escape(first_name.strip())
            if not re.match(r"^[a-zA-Z\s\-\']+$", first_name):
                raise ValidationError("First name contains invalid characters.")
        return first_name

    def clean_last_name(self):
        """Validate last name."""
        last_name = self.cleaned_data.get("last_name")
        if last_name:
            last_name = escape(last_name.strip())
            if not re.match(r"^[a-zA-Z\s\-\']+$", last_name):
                raise ValidationError("Last name contains invalid characters.")
        return last_name

    def save(self, commit=True):
        """Save user with additional fields."""
        user = super().save(commit=False)
        user.email = self.cleaned_data["email"]
        user.first_name = self.cleaned_data["first_name"]
        user.last_name = self.cleaned_data["last_name"]

        if commit:
            user.save()
        return user


class SecureContactForm(forms.Form):
    """
    Secure contact form for general inquiries.
    """

    subject = forms.CharField(
        max_length=200,
        required=True,
        widget=forms.TextInput(
            attrs={"class": "form-control", "placeholder": "Enter subject"}
        ),
        help_text="Brief subject line for your message",
    )

    name = forms.CharField(
        max_length=100,
        required=True,
        widget=forms.TextInput(
            attrs={
                "class": "form-control",
                "placeholder": "Enter your full name",
                "autocomplete": "name",
            }
        ),
        help_text="Enter your full name",
    )

    email = forms.EmailField(
        required=True,
        widget=forms.EmailInput(
            attrs={
                "class": "form-control",
                "placeholder": "Enter your email address",
                "autocomplete": "email",
            }
        ),
        help_text="We'll use this to respond to your message",
    )

    phone = forms.CharField(
        max_length=20,
        required=False,
        widget=forms.TextInput(
            attrs={
                "class": "form-control",
                "placeholder": "Enter phone number (optional)",
                "autocomplete": "tel",
            }
        ),
        help_text="Phone number (optional)",
    )

    message = forms.CharField(
        widget=forms.Textarea(
            attrs={
                "class": "form-control",
                "rows": 6,
                "placeholder": "Enter your message...",
                "maxlength": "2000",
            }
        ),
        max_length=2000,
        required=True,
        help_text="Detailed message (maximum 2000 characters)",
    )

    # Honeypot field for spam protection
    website = forms.CharField(
        required=False, widget=forms.HiddenInput(), help_text="Leave this field empty"
    )

    def clean_subject(self):
        """Validate subject line."""
        subject = self.cleaned_data.get("subject")
        if subject:
            subject = escape(subject.strip())
            if len(subject) < 3:
                raise ValidationError("Subject must be at least 3 characters long.")
        return subject

    def clean_phone(self):
        """Validate phone number format."""
        phone = self.cleaned_data.get("phone")
        if phone:
            # Remove spaces, hyphens, parentheses, and plus signs for validation
            phone_clean = re.sub(r"[\s\-\(\)\+]", "", phone)
            if not re.match(r"^\d{10,15}$", phone_clean):
                raise ValidationError("Please enter a valid phone number.")
            return phone.strip()
        return phone

    def clean_website(self):
        """Honeypot validation - should always be empty."""
        website = self.cleaned_data.get("website")
        if website:
            # This indicates a bot filled out the honeypot field
            raise ValidationError("Spam detected.")
        return website

    def clean_message(self):
        """Validate message content."""
        message = self.cleaned_data.get("message")
        if message:
            message = escape(message.strip())

            if len(message) < 20:
                raise ValidationError("Message must be at least 20 characters long.")

            # Basic spam detection
            spam_patterns = [
                r"http[s]?://",
                r"www\.",
                r"click.*here",
                r"buy.*now",
                r"free.*money",
                r"guaranteed.*income",
            ]

            for pattern in spam_patterns:
                if re.search(pattern, message, re.IGNORECASE):
                    raise ValidationError("Message contains prohibited content.")

        return message
