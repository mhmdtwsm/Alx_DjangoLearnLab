#!/bin/bash
# write_files.sh - Write all required Django blog files for Task 0

set -e

APP_NAME="blog"
PROJECT_NAME="django_blog"

# 1. settings.py
cat > $PROJECT_NAME/settings.py <<'EOF'
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = "django-insecure-change-this"

DEBUG = True
ALLOWED_HOSTS = []

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'blog',  # our app
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'django_blog.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / "templates"],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'django_blog.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / "db.sqlite3",
    }
}

AUTH_PASSWORD_VALIDATORS = []

LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True

STATIC_URL = "static/"
STATICFILES_DIRS = [BASE_DIR / "static"]
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
EOF

# 2. project urls.py
cat > $PROJECT_NAME/urls.py <<'EOF'
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('blog.urls')),
]
EOF

# 3. blog/models.py
cat > $APP_NAME/models.py <<'EOF'
from django.db import models
from django.contrib.auth.models import User

class Post(models.Model):
    title = models.CharField(max_length=200)
    content = models.TextField()
    published_date = models.DateTimeField(auto_now_add=True)
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name="posts")

    def __str__(self):
        return self.title
EOF

# 4. blog/views.py
cat > $APP_NAME/views.py <<'EOF'
from django.shortcuts import render
from .models import Post

def home(request):
    posts = Post.objects.all().order_by("-published_date")
    return render(request, "blog/home.html", {"posts": posts})
EOF

# 5. blog/urls.py
cat > $APP_NAME/urls.py <<'EOF'
from django.urls import path
from . import views

urlpatterns = [
    path("", views.home, name="home"),
]
EOF

# 6. template
mkdir -p $APP_NAME/templates/$APP_NAME
cat > $APP_NAME/templates/$APP_NAME/home.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Django Blog</title>
    <link rel="stylesheet" href="{% static 'blog/css/style.css' %}">
</head>
<body>
    <h1>Welcome to Django Blog</h1>
    <hr>
    {% for post in posts %}
        <h2>{{ post.title }}</h2>
        <p>By {{ post.author.username }} on {{ post.published_date }}</p>
        <p>{{ post.content }}</p>
        <hr>
    {% empty %}
        <p>No posts yet.</p>
    {% endfor %}
</body>
</html>
EOF

# 7. static CSS
mkdir -p $APP_NAME/static/$APP_NAME/css
cat > $APP_NAME/static/$APP_NAME/css/style.css <<'EOF'
body {
    font-family: Arial, sans-serif;
    margin: 40px;
    background: #f9f9f9;
}

h1 {
    color: #333;
}
EOF

echo "✅ All files written successfully."
echo "Next steps:"
echo "1. source venv/bin/activate"
echo "2. python manage.py makemigrations"
echo "3. python manage.py migrate"
echo "4. python manage.py runserver"

