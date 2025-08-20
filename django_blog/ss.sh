#!/bin/bash

# Script to add comment functionality to the blog app
# Project: django_blog
# App: blog

set -e

APP_DIR="django_blog/blog"

echo ">>> Creating Comment model..."
cat > $APP_DIR/models.py << 'EOF'
from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
from .models import Post

class Comment(models.Model):
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name="comments")
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    content = models.TextField()
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Comment by {self.author} on {self.post}"
EOF

echo ">>> Creating forms.py for CommentForm..."
cat > $APP_DIR/forms.py << 'EOF'
from django import forms
from .models import Comment

class CommentForm(forms.ModelForm):
    class Meta:
        model = Comment
        fields = ["content"]
        widgets = {
            "content": forms.Textarea(attrs={"rows": 3, "placeholder": "Write your comment..."})
        }
EOF

echo ">>> Creating comment views..."
cat > $APP_DIR/views.py << 'EOF'
from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.views.generic import UpdateView, DeleteView
from django.urls import reverse_lazy
from .models import Post, Comment
from .forms import CommentForm

@login_required
def add_comment(request, post_id):
    post = get_object_or_404(Post, id=post_id)
    if request.method == "POST":
        form = CommentForm(request.POST)
        if form.is_valid():
            comment = form.save(commit=False)
            comment.post = post
            comment.author = request.user
            comment.save()
            return redirect("post-detail", pk=post.id)
    else:
        form = CommentForm()
    return render(request, "blog/comment_form.html", {"form": form})

class CommentUpdateView(LoginRequiredMixin, UserPassesTestMixin, UpdateView):
    model = Comment
    form_class = CommentForm
    template_name = "blog/comment_form.html"

    def form_valid(self, form):
        form.instance.author = self.request.user
        return super().form_valid(form)

    def get_success_url(self):
        return reverse_lazy("post-detail", kwargs={"pk": self.object.post.id})

    def test_func(self):
        comment = self.get_object()
        return self.request.user == comment.author

class CommentDeleteView(LoginRequiredMixin, UserPassesTestMixin, DeleteView):
    model = Comment
    template_name = "blog/comment_confirm_delete.html"

    def get_success_url(self):
        return reverse_lazy("post-detail", kwargs={"pk": self.object.post.id})

    def test_func(self):
        comment = self.get_object()
        return self.request.user == comment.author
EOF

echo ">>> Creating comment templates..."
mkdir -p $APP_DIR/templates/blog

cat > $APP_DIR/templates/blog/comment_form.html << 'EOF'
{% extends "blog/base.html" %}
{% block content %}
  <h2>{% if object %}Edit Comment{% else %}Add Comment{% endif %}</h2>
  <form method="POST">
    {% csrf_token %}
    {{ form.as_p }}
    <button type="submit" class="btn btn-primary">Submit</button>
  </form>
{% endblock %}
EOF

cat > $APP_DIR/templates/blog/comment_confirm_delete.html << 'EOF'
{% extends "blog/base.html" %}
{% block content %}
  <h2>Delete Comment</h2>
  <p>Are you sure you want to delete this comment?</p>
  <form method="POST">
    {% csrf_token %}
    <button type="submit" class="btn btn-danger">Delete</button>
    <a href="{% url 'post-detail' object.post.id %}" class="btn btn-secondary">Cancel</a>
  </form>
{% endblock %}
EOF

echo ">>> Updating urls.py..."
cat > $APP_DIR/urls.py << 'EOF'
from django.urls import path
from . import views
from .views import CommentUpdateView, CommentDeleteView

urlpatterns = [
    # Post URLs (already existing)
    path("post/<int:post_id>/comment/new/", views.add_comment, name="add-comment"),
    path("comment/<int:pk>/edit/", CommentUpdateView.as_view(), name="edit-comment"),
    path("comment/<int:pk>/delete/", CommentDeleteView.as_view(), name="delete-comment"),
]
EOF

echo ">>> Adding comment section to post_detail template..."
cat > $APP_DIR/templates/blog/post_detail.html << 'EOF'
{% extends "blog/base.html" %}
{% block content %}
  <h1>{{ object.title }}</h1>
  <p>{{ object.content }}</p>
  <p><small>By {{ object.author }} on {{ object.date_posted }}</small></p>

  <hr>
  <h3>Comments</h3>
  {% for comment in object.comments.all %}
    <div>
      <p>{{ comment.content }}</p>
      <small>by {{ comment.author }} on {{ comment.created_at }}</small>
      {% if comment.author == user %}
        <a href="{% url 'edit-comment' comment.id %}">Edit</a> |
        <a href="{% url 'delete-comment' comment.id %}">Delete</a>
      {% endif %}
    </div>
    <hr>
  {% empty %}
    <p>No comments yet.</p>
  {% endfor %}

  {% if user.is_authenticated %}
    <h4>Add a Comment</h4>
    <form action="{% url 'add-comment' object.id %}" method="POST">
      {% csrf_token %}
      <textarea name="content" rows="3" placeholder="Write your comment..."></textarea>
      <br>
      <button type="submit" class="btn btn-primary">Post Comment</button>
    </form>
  {% else %}
    <p><a href="{% url 'login' %}">Login</a> to add a comment.</p>
  {% endif %}
{% endblock %}
EOF

echo ">>> Done! Now run migrations."
echo ">>> Run: python manage.py makemigrations && python manage.py migrate"

