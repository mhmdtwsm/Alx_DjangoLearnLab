from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from .models import Book
from django.contrib.auth.models import User


class BookAPITests(APITestCase):

    def setUp(self):
        # Create a test user
        self.user = User.objects.create_user(username="tester", password="pass123")
        self.client.login(username="tester", password="pass123")

        # Create some sample books
        self.book1 = Book.objects.create(title="Django Basics", author="John Doe", publication_year=2020)
        self.book2 = Book.objects.create(title="Advanced Python", author="Jane Doe", publication_year=2021)

        self.list_url = reverse('book-list')
        self.detail_url = lambda pk: reverse('book-detail', args=[pk])

    def test_list_books(self):
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(len(response.data), 2)

    def test_create_book(self):
        data = {"title": "New Book", "author": "Author Test", "publication_year": 2023}
        response = self.client.post(self.list_url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Book.objects.count(), 3)

    def test_retrieve_book(self):
        response = self.client.get(self.detail_url(self.book1.pk))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['title'], "Django Basics")

    def test_update_book(self):
        data = {"title": "Django Updated", "author": "John Doe", "publication_year": 2020}
        response = self.client.put(self.detail_url(self.book1.pk), data, format="json")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.book1.refresh_from_db()
        self.assertEqual(self.book1.title, "Django Updated")

    def test_delete_book(self):
        response = self.client.delete(self.detail_url(self.book1.pk))
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(Book.objects.count(), 1)

    def test_filter_books_by_author(self):
        response = self.client.get(f"{self.list_url}?author=Jane")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['author'], "Jane Doe")

    def test_search_books(self):
        response = self.client.get(f"{self.list_url}?search=Django")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['title'], "Django Basics")

    def test_order_books_by_title(self):
        response = self.client.get(f"{self.list_url}?ordering=title")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        titles = [book['title'] for book in response.data]
        self.assertEqual(titles, sorted(titles))
