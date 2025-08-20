from django.urls import path
from . import views
from .views import CommentUpdateView, CommentDeleteView

urlpatterns = [
    # Post URLs (already existing)
    path("post/<int:post_id>/comment/new/", views.add_comment, name="add-comment"),
    path("comment/<int:pk>/edit/", CommentUpdateView.as_view(), name="edit-comment"),
    path("comment/<int:pk>/delete/", CommentDeleteView.as_view(), name="delete-comment"),
]
