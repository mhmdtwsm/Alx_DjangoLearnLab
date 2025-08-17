from rest_framework import generics, status
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
        'List Books': '/api/books/',
        'API Overview': '/api/',
    }
    return JsonResponse(api_urls)
