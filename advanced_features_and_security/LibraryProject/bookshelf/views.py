from django.shortcuts import render, redirect, get_object_or_404
from django.http import HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_protect
from django.views.decorators.http import require_http_methods
from django.contrib import messages
from django.core.paginator import Paginator
from django.db.models import Q
from django.utils.html import escape
from django.core.exceptions import ValidationError
import logging

# Import your models and forms - INCLUDING ExampleForm
from .models import Book
from .forms import (
    BookSearchForm,
    SecureBookForm,
    SecureCommentForm,
    ExampleForm,
    SecureContactForm,
    SecureUserRegistrationForm,
)

# Set up security logging
security_logger = logging.getLogger("django.security")


@csrf_protect
@require_http_methods(["GET", "POST"])
def example_form_view(request):
    """
    Secure view for handling ExampleForm submissions.
    Demonstrates proper form handling with CSRF protection and validation.
    """
    if request.method == "POST":
        form = ExampleForm(request.POST)
        if form.is_valid():
            # Process validated form data
            name = form.cleaned_data["name"]
            email = form.cleaned_data["email"]
            age = form.cleaned_data.get("age")
            message = form.cleaned_data["message"]
            newsletter = form.cleaned_data.get("newsletter", False)
            category = form.cleaned_data["category"]

            # Log successful form submission
            security_logger.info(f"Example form submitted by: {name} ({email})")

            # Here you would typically save the data or send an email
            # For demonstration, we'll just show a success message
            messages.success(
                request,
                f"Thank you, {escape(name)}! Your {
                    category
                } inquiry has been received.",
            )

            # Redirect to prevent duplicate submissions
            return redirect("example_form")

        else:
            # Log form validation failures
            security_logger.warning(
                f"Invalid example form submission from IP: {
                    request.META.get('REMOTE_ADDR')
                }"
            )
            messages.error(request, "Please correct the errors below.")
    else:
        form = ExampleForm()

    context = {"form": form, "page_title": "Example Form - Security Demo"}

    return render(request, "bookshelf/example_form.html", context)


@csrf_protect
@require_http_methods(["GET", "POST"])
def secure_book_list(request):
    """
    Secure view for displaying and searching books.
    Implements CSRF protection, input validation, and XSS prevention.
    """
    books = Book.objects.all()
    form = BookSearchForm()

    if request.method == "POST":
        form = BookSearchForm(request.POST)
        if form.is_valid():
            # Safe search using Django ORM - prevents SQL injection
            query = form.cleaned_data["query"]
            search_type = form.cleaned_data.get("search_type", "all")

            # Log search attempts for security monitoring
            security_logger.info(
                f"Book search performed: {query} (type: {search_type})"
            )

            # Use Django ORM's safe query methods - NO raw SQL
            if search_type == "title":
                books = Book.objects.filter(title__icontains=query)
            elif search_type == "author":
                books = Book.objects.filter(author__icontains=query)
            elif search_type == "isbn":
                books = Book.objects.filter(isbn__icontains=query)
            else:  # search_type == 'all'
                books = Book.objects.filter(
                    Q(title__icontains=query)
                    | Q(author__icontains=query)
                    | Q(description__icontains=query)
                ).distinct()

            # Limit results to prevent performance issues
            books = books[:100]
        else:
            # Log invalid search attempts
            security_logger.warning(
                f"Invalid search attempt from IP: {request.META.get('REMOTE_ADDR')}"
            )

    # Implement pagination for better performance
    paginator = Paginator(books, 10)  # Show 10 books per page
    page_number = request.GET.get("page")
    books_page = paginator.get_page(page_number)

    context = {
        "books": books_page,
        "form": form,
    }

    return render(request, "bookshelf/book_list.html", context)


@csrf_protect
@require_http_methods(["GET", "POST"])
def secure_book_create(request):
    """
    Secure view for creating books with comprehensive input validation.
    """
    if request.method == "POST":
        # Check for honeypot (anti-spam measure)
        if request.POST.get("honeypot"):
            security_logger.warning(
                f"Honeypot triggered from IP: {request.META.get('REMOTE_ADDR')}"
            )
            return HttpResponse("Invalid request", status=400)

        form = SecureBookForm(request.POST)
        if form.is_valid():
            try:
                # Create book using validated data - prevents injection
                book = Book.objects.create(
                    title=form.cleaned_data["title"],
                    author=form.cleaned_data["author"],
                    publication_year=form.cleaned_data["publication_year"],
                    isbn=form.cleaned_data.get("isbn", ""),
                    description=form.cleaned_data.get("description", ""),
                )

                # Log successful book creation
                security_logger.info(f"Book created: {book.title} by {request.user}")

                messages.success(request, "Book added successfully!")
                return redirect("secure_book_list")

            except Exception as e:
                security_logger.error(f"Error creating book: {str(e)}")
                messages.error(request, "Error adding book. Please try again.")
        else:
            # Log form validation failures
            security_logger.warning(
                f"Invalid book creation attempt from IP: {
                    request.META.get('REMOTE_ADDR')
                }"
            )
    else:
        form = SecureBookForm()

    return render(request, "bookshelf/form_example.html", {"form": form})


@csrf_protect
@require_http_methods(["POST"])
def secure_book_search(request):
    """
    Dedicated secure search endpoint with rate limiting considerations.
    """
    # Basic rate limiting check (in production, use django-ratelimit)
    session_searches = request.session.get("search_count", 0)
    if session_searches > 50:  # Limit searches per session
        security_logger.warning(
            f"Search rate limit exceeded for IP: {request.META.get('REMOTE_ADDR')}"
        )
        return JsonResponse(
            {"error": "Too many searches. Please try again later."}, status=429
        )

    form = BookSearchForm(request.POST)
    if form.is_valid():
        query = form.cleaned_data["query"]
        search_type = form.cleaned_data.get("search_type", "all")

        # Increment search counter
        request.session["search_count"] = session_searches + 1

        # Safe search using ORM based on search type
        if search_type == "title":
            books = Book.objects.filter(title__icontains=query)
        elif search_type == "author":
            books = Book.objects.filter(author__icontains=query)
        elif search_type == "isbn":
            books = Book.objects.filter(isbn__icontains=query)
        else:
            books = Book.objects.filter(
                Q(title__icontains=query)
                | Q(author__icontains=query)
                | Q(description__icontains=query)
            )

        books_data = books.values("title", "author", "publication_year", "isbn")[:20]

        return JsonResponse(
            {
                "books": list(books_data),
                "query": escape(query),  # Escape for safe display
                "search_type": search_type,
            }
        )

    return JsonResponse({"error": "Invalid search query"}, status=400)


@csrf_protect
@require_http_methods(["POST"])
def secure_add_comment(request):
    """
    Secure comment addition with XSS protection.
    """
    form = SecureCommentForm(request.POST)
    if form.is_valid():
        name = form.cleaned_data["name"]
        email = form.cleaned_data.get("email")
        comment_text = form.cleaned_data["comment"]
        rating = form.cleaned_data.get("rating")

        # Here you would save the comment to your model
        # comment = Comment.objects.create(
        #     name=name,
        #     email=email,
        #     text=comment_text,
        #     rating=rating,
        #     user=request.user if request.user.is_authenticated else None
        # )

        security_logger.info(f"Comment added by: {name}")
        messages.success(
            request, f"Thank you, {escape(name)}! Your comment has been added."
        )

    else:
        security_logger.warning(
            f"Invalid comment attempt from IP: {request.META.get('REMOTE_ADDR')}"
        )
        messages.error(request, "Invalid comment. Please check your input.")

    return redirect("secure_book_list")


def secure_book_detail(request, book_id):
    """
    Secure book detail view with safe parameter handling.
    """
    # Use get_object_or_404 to safely handle the ID parameter
    # This prevents SQL injection through URL parameters
    book = get_object_or_404(Book, id=book_id)

    # Initialize comment form for the detail page
    comment_form = SecureCommentForm()

    context = {
        "book": book,
        "comment_form": comment_form,
    }

    return render(request, "bookshelf/book_detail.html", context)


@csrf_protect
@require_http_methods(["GET", "POST"])
def secure_contact_view(request):
    """
    Secure contact form view with comprehensive validation.
    """
    if request.method == "POST":
        form = SecureContactForm(request.POST)
        if form.is_valid():
            # Process the contact form
            subject = form.cleaned_data["subject"]
            name = form.cleaned_data["name"]
            email = form.cleaned_data["email"]
            phone = form.cleaned_data.get("phone")
            message = form.cleaned_data["message"]

            # Log contact form submission
            security_logger.info(
                f"Contact form submitted by: {name} ({email}) - Subject: {subject}"
            )

            # Here you would typically send an email or save to database
            # send_mail(subject, message, email, ['admin@example.com'])

            messages.success(
                request,
                f"Thank you, {escape(name)}! Your message has been sent successfully. "
                f"We'll respond to {escape(email)} within 24 hours.",
            )

            return redirect("secure_contact")

        else:
            # Log validation failures
            security_logger.warning(
                f"Invalid contact form submission from IP: {
                    request.META.get('REMOTE_ADDR')
                }"
            )
    else:
        form = SecureContactForm()

    context = {"form": form, "page_title": "Contact Us - Secure Form"}

    return render(request, "bookshelf/contact_form.html", context)


@csrf_protect
@require_http_methods(["GET", "POST"])
def secure_user_registration(request):
    """
    Secure user registration view.
    """
    if request.method == "POST":
        form = SecureUserRegistrationForm(request.POST)
        if form.is_valid():
            try:
                user = form.save()
                security_logger.info(f"New user registered: {user.username}")

                messages.success(
                    request,
                    f"Welcome, {
                        escape(user.first_name)
                    }! Your account has been created successfully.",
                )

                return redirect("login")  # Redirect to login page

            except Exception as e:
                security_logger.error(f"Error during user registration: {str(e)}")
                messages.error(request, "Registration failed. Please try again.")
        else:
            security_logger.warning(
                f"Invalid registration attempt from IP: {
                    request.META.get('REMOTE_ADDR')
                }"
            )
    else:
        form = SecureUserRegistrationForm()

    context = {"form": form, "page_title": "Register - Create Account"}

    return render(request, "registration/register.html", context)


# Utility views for demonstration
def security_demo_view(request):
    """
    View to demonstrate various security features.
    """
    context = {
        "page_title": "Security Features Demo",
        "security_features": [
            "CSRF Protection",
            "XSS Prevention",
            "SQL Injection Protection",
            "Input Validation",
            "Rate Limiting",
            "Security Logging",
            "Honeypot Spam Protection",
            "Secure Headers",
        ],
    }

    return render(request, "bookshelf/security_demo.html", context)


# Example of what NOT to do (commented out for security):
# def vulnerable_search(request):
#     """
#     VULNERABLE CODE - DO NOT USE
#     This shows what NOT to do - SQL injection vulnerability
#     """
#     query = request.GET.get('q')
#     # NEVER DO THIS - vulnerable to SQL injection:
#     # raw_query = f"SELECT * FROM bookshelf_book WHERE title LIKE '%{query}%'"
#     # results = Book.objects.raw(raw_query)
#     pass


# Security middleware functions
def log_suspicious_activity(request, activity_type, details):
    """
    Helper function to log suspicious activities for security monitoring.
    """
    security_logger.warning(
        f"Suspicious activity detected: {activity_type} - {details} - IP: {
            request.META.get('REMOTE_ADDR')
        }"
    )


def validate_request_headers(request):
    """
    Validate request headers for security threats.
    """
    user_agent = request.META.get("HTTP_USER_AGENT", "")

    # Check for suspicious user agents
    suspicious_agents = ["sqlmap", "nikto", "nmap", "dirb"]
    if any(agent in user_agent.lower() for agent in suspicious_agents):
        log_suspicious_activity(request, "Suspicious User Agent", user_agent)
        return False

    return True


def get_client_ip(request):
    """
    Get the client's real IP address, considering proxies.
    """
    x_forwarded_for = request.META.get("HTTP_X_FORWARDED_FOR")
    if x_forwarded_for:
        ip = x_forwarded_for.split(",")[0]
    else:
        ip = request.META.get("REMOTE_ADDR")
    return ip


def rate_limit_check(request, limit=60, window=3600):
    """
    Basic rate limiting implementation.
    In production, use django-ratelimit or similar.
    """
    client_ip = get_client_ip(request)
    cache_key = f"rate_limit_{client_ip}"

    # This is a simplified implementation
    # In production, use Redis or similar for distributed rate limiting
    from django.core.cache import cache

    current_requests = cache.get(cache_key, 0)
    if current_requests >= limit:
        security_logger.warning(f"Rate limit exceeded for IP: {client_ip}")
        return False

    cache.set(cache_key, current_requests + 1, window)
    return True
