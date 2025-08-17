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

# Import your models and forms
from .models import Book
from .forms import BookSearchForm, SecureBookForm, SecureCommentForm

# Set up security logging
security_logger = logging.getLogger('django.security')

@csrf_protect
@require_http_methods(["GET", "POST"])
def secure_book_list(request):
    """
    Secure view for displaying and searching books.
    Implements CSRF protection, input validation, and XSS prevention.
    """
    books = Book.objects.all()
    form = BookSearchForm()
    
    if request.method == 'POST':
        form = BookSearchForm(request.POST)
        if form.is_valid():
            # Safe search using Django ORM - prevents SQL injection
            query = form.cleaned_data['query']
            
            # Log search attempts for security monitoring
            security_logger.info(f"Book search performed: {query}")
            
            # Use Django ORM's safe query methods - NO raw SQL
            books = Book.objects.filter(
                Q(title__icontains=query) | 
                Q(author__icontains=query)
            ).distinct()
            
            # Limit results to prevent performance issues
            books = books[:100]
        else:
            # Log invalid search attempts
            security_logger.warning(f"Invalid search attempt from IP: {request.META.get('REMOTE_ADDR')}")
    
    # Implement pagination for better performance
    paginator = Paginator(books, 10)  # Show 10 books per page
    page_number = request.GET.get('page')
    books_page = paginator.get_page(page_number)
    
    context = {
        'books': books_page,
        'form': form,
    }
    
    return render(request, 'bookshelf/book_list.html', context)


@csrf_protect  
@require_http_methods(["GET", "POST"])
def secure_book_create(request):
    """
    Secure view for creating books with comprehensive input validation.
    """
    if request.method == 'POST':
        # Check for honeypot (anti-spam measure)
        if request.POST.get('honeypot'):
            security_logger.warning(f"Honeypot triggered from IP: {request.META.get('REMOTE_ADDR')}")
            return HttpResponse('Invalid request', status=400)
            
        form = SecureBookForm(request.POST)
        if form.is_valid():
            try:
                # Create book using validated data - prevents injection
                book = Book.objects.create(
                    title=form.cleaned_data['title'],
                    author=form.cleaned_data['author'], 
                    publication_year=form.cleaned_data['publication_year']
                )
                
                # Log successful book creation
                security_logger.info(f"Book created: {book.title} by {request.user}")
                
                messages.success(request, 'Book added successfully!')
                return redirect('secure_book_list')
                
            except Exception as e:
                security_logger.error(f"Error creating book: {str(e)}")
                messages.error(request, 'Error adding book. Please try again.')
        else:
            # Log form validation failures
            security_logger.warning(f"Invalid book creation attempt from IP: {request.META.get('REMOTE_ADDR')}")
    else:
        form = SecureBookForm()
    
    return render(request, 'bookshelf/form_example.html', {'form': form})


@csrf_protect
@require_http_methods(["POST"])
def secure_book_search(request):
    """
    Dedicated secure search endpoint with rate limiting considerations.
    """
    # Basic rate limiting check (in production, use django-ratelimit)
    session_searches = request.session.get('search_count', 0)
    if session_searches > 50:  # Limit searches per session
        security_logger.warning(f"Search rate limit exceeded for IP: {request.META.get('REMOTE_ADDR')}")
        return JsonResponse({'error': 'Too many searches. Please try again later.'}, status=429)
    
    form = BookSearchForm(request.POST)
    if form.is_valid():
        query = form.cleaned_data['query']
        
        # Increment search counter
        request.session['search_count'] = session_searches + 1
        
        # Safe search using ORM
        books = Book.objects.filter(
            Q(title__icontains=query) | 
            Q(author__icontains=query)
        ).values('title', 'author', 'publication_year')[:20]  # Limit results
        
        return JsonResponse({
            'books': list(books),
            'query': escape(query)  # Escape for safe display
        })
    
    return JsonResponse({'error': 'Invalid search query'}, status=400)


@csrf_protect
@require_http_methods(["POST"])
def secure_add_comment(request):
    """
    Secure comment addition with XSS protection.
    """
    form = SecureCommentForm(request.POST)
    if form.is_valid():
        comment_text = form.cleaned_data['comment']
        
        # Here you would save the comment to your model
        # comment = Comment.objects.create(text=comment_text, user=request.user)
        
        security_logger.info(f"Comment added by user: {request.user}")
        messages.success(request, 'Comment added successfully!')
        
    else:
        security_logger.warning(f"Invalid comment attempt from IP: {request.META.get('REMOTE_ADDR')}")
        messages.error(request, 'Invalid comment. Please check your input.')
    
    return redirect('secure_book_list')


def secure_book_detail(request, book_id):
    """
    Secure book detail view with safe parameter handling.
    """
    # Use get_object_or_404 to safely handle the ID parameter
    # This prevents SQL injection through URL parameters
    book = get_object_or_404(Book, id=book_id)
    
    context = {
        'book': book,
    }
    
    return render(request, 'bookshelf/book_detail.html', context)


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
    security_logger.warning(f"Suspicious activity detected: {activity_type} - {details} - IP: {request.META.get('REMOTE_ADDR')}")


def validate_request_headers(request):
    """
    Validate request headers for security threats.
    """
    user_agent = request.META.get('HTTP_USER_AGENT', '')
    
    # Check for suspicious user agents
    suspicious_agents = ['sqlmap', 'nikto', 'nmap', 'dirb']
    if any(agent in user_agent.lower() for agent in suspicious_agents):
        log_suspicious_activity(request, 'Suspicious User Agent', user_agent)
        return False
        
    return True
