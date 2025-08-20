#!/bin/bash
# Script to enable Filtering, Searching, and Ordering in Django REST Framework
# Project: advanced-api-project

set -e

PROJECT_DIR="$(pwd)"
API_DIR="$PROJECT_DIR/api"

echo "[*] Adding django-filter to requirements.txt..."
grep -qxF "django-filter" "$PROJECT_DIR/requirements.txt" || echo "django-filter" >> "$PROJECT_DIR/requirements.txt"

echo "[*] Writing api/filters.py..."
cat > "$API_DIR/filters.py" <<'EOF'
import django_filters
from .models import Book

class BookFilter(django_filters.FilterSet):
    title = django_filters.CharFilter(lookup_expr='icontains')
    author = django_filters.CharFilter(lookup_expr='icontains')
    publication_year = django_filters.NumberFilter()

    class Meta:
        model = Book
        fields = ['title', 'author', 'publication_year']
EOF

echo "[*] Writing api/views.py..."
cat > "$API_DIR/views.py" <<'EOF'
from rest_framework import generics, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Book
from .serializers import BookSerializer
from .filters import BookFilter

class BookListView(generics.ListCreateAPIView):
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class = BookFilter
    search_fields = ['title', 'author']
    ordering_fields = ['title', 'publication_year']

class BookDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Book.objects.all()
    serializer_class = BookSerializer
EOF

echo "[*] Writing api/urls.py..."
cat > "$API_DIR/urls.py" <<'EOF'
from django.urls import path
from .views import BookListView, BookDetailView

urlpatterns = [
    path('books/', BookListView.as_view(), name='book-list'),
    path('books/<int:pk>/', BookDetailView.as_view(), name='book-detail'),
]
EOF

echo "[*] Done!"
echo ">>> Next step: In advanced_api_project/settings.py, add:"
echo "    'django_filters' to INSTALLED_APPS"
echo ""
echo ">>> Example usage after running the server:"
echo "    /api/books/?title=python"
echo "    /api/books/?author=doe"
echo "    /api/books/?search=django"
echo "    /api/books/?ordering=title"

