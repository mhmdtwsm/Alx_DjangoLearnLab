#!/bin/bash

# Script: setup_blog_crud.sh
# Purpose: Auto-generate CRUD files for Blog Post Management in django_blog project
# Repo: Alx_DjangoLearnLab
# Directory: django_blog/blog

APP_DIR="django_blog/blog"
TEMPLATES_DIR="$APP_DIR/templates/blog"

mkdir -p $TEMPLATES_DIR

# ========================
# models.py
# ========================
cat > $APP_DIR/models.py << 'EOF'
from django.db import models
from django.contrib.auth.models import User
from django.urls import reverse

class Post(models.Model):
    title = models.CharField(max_length=200)
    content = models.TextField()
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title

    def get_absolute_url(self):
        return reverse("post-detail", kwargs={"pk": self.pk})
EOF

# ========================
# forms.py
# ========================
cat > $APP_DIR/forms.py << 'EOF'
from django import forms
from .models import Post

class PostForm(forms.ModelForm):
    class Meta:
        model = Post
        fields = ['title', 'content']
EOF

# ========================
# views.py
# ========================
cat > $APP_DIR/views.py << 'EOF'
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.views.generic import ListView, DetailView, CreateView, UpdateView, DeleteView
from django.urls import reverse_lazy
from .models import Post
from .forms import PostForm

class PostListView(ListView):
    model = Post
    template_name = "blog/post_list.html"
    context_object_name = "posts"
    ordering = ['-created_at']

class PostDetailView(DetailView):
    model = Post
    template_name = "blog/post_detail.html"

class PostCreateView(LoginRequiredMixin, CreateView):
    model = Post
    form_class = PostForm
    template_name = "blog/post_form.html"

    def form_valid(self, form):
        form.instance.author = self.request.user
        return super().form_valid(form)

class PostUpdateView(LoginRequiredMixin, UserPassesTestMixin, UpdateView):
    model = Post
    form_class = PostForm
    template_name = "blog/post_form.html"

    def form_valid(self, form):
        form.instance.author = self.request.user
        return super().form_valid(form)

    def test_func(self):
        post = self.get_object()
        return self.request.user == post.author

class PostDeleteView(LoginRequiredMixin, UserPassesTestMixin, DeleteView):
    model = Post
    template_name = "blog/post_confirm_delete.html"
    success_url = reverse_lazy("post-list")

    def test_func(self):
        post = self.get_object()
        return self.request.user == post.author
EOF

# ========================
# urls.py
# ========================
cat > $APP_DIR/urls.py << 'EOF'
from django.urls import path
from .views import (
    PostListView, PostDetailView,
    PostCreateView, PostUpdateView, PostDeleteView
)

urlpatterns = [
    path("posts/", PostListView.as_view(), name="post-list"),
    path("posts/new/", PostCreateView.as_view(), name="post-create"),
    path("posts/<int:pk>/", PostDetailView.as_view(), name="post-detail"),
    path("posts/<int:pk>/edit/", PostUpdateView.as_view(), name="post-update"),
    path("posts/<int:pk>/delete/", PostDeleteView.as_view(), name="post-delete"),
]
EOF

# ========================
# Templates
# ========================

# Post list template
cat > $TEMPLATES_DIR/post_list.html << 'EOF'
{% extends "base.html" %}
{% block content %}
  <h1>All Posts</h1>
  <a href="{% url 'post-create' %}">Create New Post</a>
  <ul>
    {% for post in posts %}
      <li>
        <a href="{% url 'post-detail' post.pk %}">{{ post.title }}</a>
        <p>{{ post.content|truncatechars:100 }}</p>
      </li>
    {% empty %}
      <li>No posts yet.</li>
    {% endfor %}
  </ul>
{% endblock %}
EOF

# Post detail template
cat > $TEMPLATES_DIR/post_detail.html << 'EOF'
{% extends "base.html" %}
{% block content %}
  <h1>{{ object.title }}</h1>
  <p>{{ object.content }}</p>
  <p>By {{ object.author }} on {{ object.created_at }}</p>
  {% if user == object.author %}
    <a href="{% url 'post-update' object.pk %}">Edit</a> |
    <a href="{% url 'post-delete' object.pk %}">Delete</a>
  {% endif %}
  <a href="{% url 'post-list' %}">Back to all posts</a>
{% endblock %}
EOF

# Post form template
cat > $TEMPLATES_DIR/post_form.html << 'EOF'
{% extends "base.html" %}
{% block content %}
  <h1>{% if object %}Edit Post{% else %}New Post{% endif %}</h1>
  <form method="post">
    {% csrf_token %}
    {{ form.as_p }}
    <button type="submit">Save</button>
  </form>
  <a href="{% url 'post-list' %}">Cancel</a>
{% endblock %}
EOF

# Post delete template
cat > $TEMPLATES_DIR/post_confirm_delete.html << 'EOF'
{% extends "base.html" %}
{% block content %}
  <h1>Delete Post</h1>
  <p>Are you sure you want to delete "{{ object.title }}"?</p>
  <form method="post">
    {% csrf_token %}
    <button type="submit">Yes, delete</button>
  </form>
  <a href="{% url 'post-detail' object.pk %}">Cancel</a>
{% endblock %}
EOF

echo "✅ Blog CRUD setup completed in $APP_DIR"

