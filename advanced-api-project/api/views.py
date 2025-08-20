from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticatedOrReadOnly, IsAuthenticated
from django.shortcuts import get_object_or_404
from .models import Book
from .serializers import BookSerializer

# API Home view for testing


@api_view(["GET"])
def api_home(request):
    """
    API Home endpoint that provides information about available endpoints.
    """
    return Response(
        {
            "message": "Welcome to the Advanced API Project!",
            "status": "Generic Views implemented",
            "endpoints": {
                "books_list": "/api/books/",
                "book_detail": "/api/books/<id>/",
                "book_create": "/api/books/create/",
                "book_update": "/api/books/update/<id>/",
                "book_delete": "/api/books/delete/<id>/",
            },
            "authentication": "Token authentication required for write operations",
            "permissions": "Read-only for anonymous users, full CRUD for authenticated users",
        }
    )


class BookListView(generics.ListAPIView):
    """
    Generic ListView for retrieving all books.
    Allows read-only access to both authenticated and unauthenticated users.
    """

    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        """
        Optionally filter books by title or author using query parameters.
        Example: /api/books/?title=django or /api/books/?author=smith
        """
        queryset = Book.objects.all()
        title = self.request.query_params.get("title")
        author = self.request.query_params.get("author")

        if title is not None:
            queryset = queryset.filter(title__icontains=title)
        if author is not None:
            queryset = queryset.filter(author__icontains=author)

        return queryset.order_by("title")


class BookDetailView(generics.RetrieveAPIView):
    """
    Generic DetailView for retrieving a single book by ID.
    Allows read-only access to both authenticated and unauthenticated users.
    """

    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    lookup_field = "pk"

    def get_object(self):
        """
        Custom method to get object with proper error handling.
        """
        pk = self.kwargs.get("pk")
        return get_object_or_404(Book, pk=pk)


class BookCreateView(generics.CreateAPIView):
    """
    Generic CreateView for adding a new book.
    Requires authentication to create new books.
    """

    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        """
        Custom create method to add additional functionality.
        You can add custom logic here, such as setting the created_by field.
        """
        # Example: If you had a created_by field, you could set it here
        # serializer.save(created_by=self.request.user)
        serializer.save()

    def create(self, request, *args, **kwargs):
        """
        Override create method to provide custom response format.
        """
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            self.perform_create(serializer)
            return Response(
                {"message": "Book created successfully", "data": serializer.data},
                status=status.HTTP_201_CREATED,
            )
        return Response(
            {"message": "Failed to create book", "errors": serializer.errors},
            status=status.HTTP_400_BAD_REQUEST,
        )


class BookUpdateView(generics.UpdateAPIView):
    """
    Generic UpdateView for modifying an existing book.
    Requires authentication to update books.
    Supports both PUT (full update) and PATCH (partial update).
    """

    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = "pk"

    def get_object(self):
        """
        Custom method to get object with proper error handling.
        """
        pk = self.kwargs.get("pk")
        return get_object_or_404(Book, pk=pk)

    def perform_update(self, serializer):
        """
        Custom update method to add additional functionality.
        """
        serializer.save()

    def update(self, request, *args, **kwargs):
        """
        Override update method to provide custom response format.
        """
        partial = kwargs.pop("partial", False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)

        if serializer.is_valid():
            self.perform_update(serializer)
            return Response(
                {"message": "Book updated successfully", "data": serializer.data}
            )
        return Response(
            {"message": "Failed to update book", "errors": serializer.errors},
            status=status.HTTP_400_BAD_REQUEST,
        )


class BookDeleteView(generics.DestroyAPIView):
    """
    Generic DeleteView for removing a book.
    Requires authentication to delete books.
    """

    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = "pk"

    def get_object(self):
        """
        Custom method to get object with proper error handling.
        """
        pk = self.kwargs.get("pk")
        return get_object_or_404(Book, pk=pk)

    def destroy(self, request, *args, **kwargs):
        """
        Override destroy method to provide custom response format.
        """
        instance = self.get_object()
        book_title = instance.title
        self.perform_destroy(instance)
        return Response(
            {"message": f'Book "{book_title}" deleted successfully'},
            status=status.HTTP_200_OK,
        )


# Alternative: Combined CRUD views using mixins (commented out for reference)
"""
from rest_framework import mixins

class BookListCreateView(mixins.ListModelMixin,
                        mixins.CreateModelMixin,
                        generics.GenericAPIView):
    
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    
    def get(self, request, *args, **kwargs):
        return self.list(request, *args, **kwargs)
    
    def post(self, request, *args, **kwargs):
        return self.create(request, *args, **kwargs)


class BookDetailUpdateDeleteView(mixins.RetrieveModelMixin,
                                mixins.UpdateModelMixin,
                                mixins.DestroyModelMixin,
                                generics.GenericAPIView):
    
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    
    def get(self, request, *args, **kwargs):
        return self.retrieve(request, *args, **kwargs)
    
    def put(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)
    
    def patch(self, request, *args, **kwargs):
        return self.partial_update(request, *args, **kwargs)
    
    def delete(self, request, *args, **kwargs):
        return self.destroy(request, *args, **kwargs)
"""
