from rest_framework import generics, status, viewsets
from rest_framework.response import Response
from rest_framework.decorators import api_view
from django.http import JsonResponse
from .models import Book
from .serializers import BookSerializer


class BookList(generics.ListAPIView):
    """
    API view to retrieve list of books.
    
    GET /api/books/ - Returns a list of all books in JSON format
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    
    def get(self, request, *args, **kwargs):
        """
        Override get method to add custom response handling.
        """
        try:
            return super().get(request, *args, **kwargs)
        except Exception as e:
            return Response(
                {"error": "Failed to retrieve books", "details": str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class BookViewSet(viewsets.ModelViewSet):
    """
    A ViewSet for handling all CRUD operations on Book model.
    
    This ViewSet automatically provides the following endpoints:
    - GET /books_all/ - List all books
    - POST /books_all/ - Create a new book
    - GET /books_all/{id}/ - Retrieve a specific book
    - PUT /books_all/{id}/ - Update a specific book
    - PATCH /books_all/{id}/ - Partially update a specific book
    - DELETE /books_all/{id}/ - Delete a specific book
    """
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    
    def list(self, request):
        """
        Override list method to add custom response handling.
        GET /books_all/
        """
        try:
            queryset = self.get_queryset()
            serializer = self.get_serializer(queryset, many=True)
            return Response({
                'count': queryset.count(),
                'results': serializer.data
            })
        except Exception as e:
            return Response(
                {"error": "Failed to retrieve books", "details": str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def create(self, request):
        """
        Override create method to add custom response handling.
        POST /books_all/
        """
        try:
            serializer = self.get_serializer(data=request.data)
            if serializer.is_valid():
                self.perform_create(serializer)
                return Response(
                    {
                        'message': 'Book created successfully',
                        'data': serializer.data
                    }, 
                    status=status.HTTP_201_CREATED
                )
            return Response(
                {
                    'error': 'Validation failed',
                    'details': serializer.errors
                }, 
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return Response(
                {"error": "Failed to create book", "details": str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def retrieve(self, request, pk=None):
        """
        Override retrieve method to add custom response handling.
        GET /books_all/{id}/
        """
        try:
            instance = self.get_object()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except Book.DoesNotExist:
            return Response(
                {"error": "Book not found"}, 
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {"error": "Failed to retrieve book", "details": str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def update(self, request, pk=None):
        """
        Override update method to add custom response handling.
        PUT /books_all/{id}/
        """
        try:
            instance = self.get_object()
            serializer = self.get_serializer(instance, data=request.data)
            if serializer.is_valid():
                self.perform_update(serializer)
                return Response(
                    {
                        'message': 'Book updated successfully',
                        'data': serializer.data
                    }
                )
            return Response(
                {
                    'error': 'Validation failed',
                    'details': serializer.errors
                }, 
                status=status.HTTP_400_BAD_REQUEST
            )
        except Book.DoesNotExist:
            return Response(
                {"error": "Book not found"}, 
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {"error": "Failed to update book", "details": str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def partial_update(self, request, pk=None):
        """
        Override partial_update method to add custom response handling.
        PATCH /books_all/{id}/
        """
        try:
            instance = self.get_object()
            serializer = self.get_serializer(instance, data=request.data, partial=True)
            if serializer.is_valid():
                self.perform_update(serializer)
                return Response(
                    {
                        'message': 'Book partially updated successfully',
                        'data': serializer.data
                    }
                )
            return Response(
                {
                    'error': 'Validation failed',
                    'details': serializer.errors
                }, 
                status=status.HTTP_400_BAD_REQUEST
            )
        except Book.DoesNotExist:
            return Response(
                {"error": "Book not found"}, 
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {"error": "Failed to partially update book", "details": str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def destroy(self, request, pk=None):
        """
        Override destroy method to add custom response handling.
        DELETE /books_all/{id}/
        """
        try:
            instance = self.get_object()
            book_title = instance.title  # Store title before deletion
            self.perform_destroy(instance)
            return Response(
                {
                    'message': f'Book "{book_title}" deleted successfully'
                }, 
                status=status.HTTP_204_NO_CONTENT
            )
        except Book.DoesNotExist:
            return Response(
                {"error": "Book not found"}, 
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {"error": "Failed to delete book", "details": str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


@api_view(['GET'])
def book_list_function_view(request):
    """
    Alternative function-based view for listing books.
    This is an example of how you could implement the same functionality
    using a function-based view instead of a class-based view.
    """
    if request.method == 'GET':
        books = Book.objects.all()
        serializer = BookSerializer(books, many=True)
        return Response(serializer.data)


def api_overview(request):
    """
    Simple view to provide API documentation/overview.
    """
    api_urls = {
        'List Books (ListAPIView)': '/api/books/',
        'CRUD Operations (ViewSet)': {
            'List all books': 'GET /api/books_all/',
            'Create book': 'POST /api/books_all/',
            'Get book by ID': 'GET /api/books_all/{id}/',
            'Update book': 'PUT /api/books_all/{id}/',
            'Partial update': 'PATCH /api/books_all/{id}/',
            'Delete book': 'DELETE /api/books_all/{id}/',
        },
        'API Overview': '/api/',
    }
    return JsonResponse(api_urls)
