#!/bin/bash

# Django Custom User Model Setup Script
# This script creates a custom user model extending AbstractUser with additional fields

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base directory
BASE_DIR="/home/mhmd/study/alx/Alx_DjangoLearnLab/advanced_features_and_security/LibraryProject"

echo -e "${BLUE}🚀 Setting up Custom User Model for Django Project${NC}"
echo "=================================================="

# Check if base directory exists
if [ ! -d "$BASE_DIR" ]; then
    echo -e "${RED}❌ Error: Base directory $BASE_DIR does not exist!${NC}"
    exit 1
fi

cd "$BASE_DIR"

echo -e "${YELLOW}📍 Working in: $(pwd)${NC}"

# Step 1: Create custom user model in bookshelf/models.py
echo -e "${BLUE}Step 1: Creating custom user model...${NC}"

# Backup original models.py
if [ -f "bookshelf/models.py" ]; then
    cp "bookshelf/models.py" "bookshelf/models.py.backup"
    echo -e "${GREEN}✅ Backed up original bookshelf/models.py${NC}"
fi

# Create new models.py with custom user model
cat > "bookshelf/models.py" << 'EOF'
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models
from django.utils.translation import gettext_lazy as _


class CustomUserManager(BaseUserManager):
    """
    Custom user manager that handles user creation and queries
    """
    def create_user(self, username, email=None, password=None, **extra_fields):
        """
        Create and return a regular user with an email and password.
        """
        if not username:
            raise ValueError(_('The Username field must be set'))
        
        if email:
            email = self.normalize_email(email)
        
        # Set default values for extra fields
        extra_fields.setdefault('is_staff', False)
        extra_fields.setdefault('is_superuser', False)
        
        user = self.model(username=username, email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, username, email=None, password=None, **extra_fields):
        """
        Create and return a superuser with an email and password.
        """
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError(_('Superuser must have is_staff=True.'))
        if extra_fields.get('is_superuser') is not True:
            raise ValueError(_('Superuser must have is_superuser=True.'))

        return self.create_user(username, email, password, **extra_fields)


class CustomUser(AbstractUser):
    """
    Custom user model extending AbstractUser with additional fields
    """
    date_of_birth = models.DateField(
        _('Date of Birth'), 
        null=True, 
        blank=True,
        help_text=_('Enter your date of birth')
    )
    
    profile_photo = models.ImageField(
        _('Profile Photo'),
        upload_to='profile_photos/',
        null=True,
        blank=True,
        help_text=_('Upload a profile photo')
    )
    
    # Use custom manager
    objects = CustomUserManager()

    class Meta:
        verbose_name = _('User')
        verbose_name_plural = _('Users')
        db_table = 'auth_user'  # Keep same table name to avoid conflicts

    def __str__(self):
        return self.username

    def get_full_name(self):
        """
        Return the first_name plus the last_name, with a space in between.
        """
        full_name = f'{self.first_name} {self.last_name}'
        return full_name.strip()

    def get_short_name(self):
        """
        Return the short name for the user.
        """
        return self.first_name


# Keep existing Book model if it exists
class Book(models.Model):
    """
    Book model for the library system
    """
    title = models.CharField(max_length=200)
    author = models.CharField(max_length=100)
    publication_year = models.IntegerField()
    
    class Meta:
        permissions = [
            ("can_view", "Can view book"),
            ("can_create", "Can create book"),
            ("can_edit", "Can edit book"),
            ("can_delete", "Can delete book"),
        ]
    
    def __str__(self):
        return self.title
EOF

echo -e "${GREEN}✅ Created custom user model in bookshelf/models.py${NC}"

# Step 2: Update bookshelf/admin.py
echo -e "${BLUE}Step 2: Setting up admin interface...${NC}"

# Backup original admin.py
if [ -f "bookshelf/admin.py" ]; then
    cp "bookshelf/admin.py" "bookshelf/admin.py.backup"
    echo -e "${GREEN}✅ Backed up original bookshelf/admin.py${NC}"
fi

# Create new admin.py
cat > "bookshelf/admin.py" << 'EOF'
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.utils.translation import gettext_lazy as _
from .models import CustomUser, Book


@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    """
    Custom user admin that includes the additional fields
    """
    # Fields to display in the admin list view
    list_display = ('username', 'email', 'first_name', 'last_name', 'date_of_birth', 'is_staff', 'is_active')
    
    # Fields that can be searched
    search_fields = ('username', 'first_name', 'last_name', 'email')
    
    # Filters for the right sidebar
    list_filter = ('is_staff', 'is_superuser', 'is_active', 'date_joined', 'date_of_birth')
    
    # Fields to display when editing a user
    fieldsets = UserAdmin.fieldsets + (
        (_('Additional Information'), {
            'fields': ('date_of_birth', 'profile_photo'),
            'classes': ('collapse',),  # Make this section collapsible
        }),
    )
    
    # Fields to display when creating a new user
    add_fieldsets = UserAdmin.add_fieldsets + (
        (_('Additional Information'), {
            'fields': ('date_of_birth', 'profile_photo'),
            'classes': ('collapse',),
        }),
    )
    
    # Read-only fields
    readonly_fields = ('date_joined', 'last_login')
    
    # Ordering
    ordering = ('username',)


@admin.register(Book)
class BookAdmin(admin.ModelAdmin):
    """
    Admin configuration for Book model
    """
    list_display = ('title', 'author', 'publication_year')
    list_filter = ('publication_year', 'author')
    search_fields = ('title', 'author')
    ordering = ('title',)
EOF

echo -e "${GREEN}✅ Set up admin interface in bookshelf/admin.py${NC}"

# Step 3: Update settings.py
echo -e "${BLUE}Step 3: Updating settings.py...${NC}"

SETTINGS_FILE="LibraryProject/settings.py"

# Backup original settings.py
if [ -f "$SETTINGS_FILE" ]; then
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup"
    echo -e "${GREEN}✅ Backed up original settings.py${NC}"
fi

# Check if settings.py exists, if not create a basic one
if [ ! -f "$SETTINGS_FILE" ]; then
    echo -e "${YELLOW}⚠️  settings.py not found, creating basic settings file...${NC}"
    mkdir -p "LibraryProject"
    cat > "$SETTINGS_FILE" << 'EOF'
import os
from pathlib import Path

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'django-insecure-your-secret-key-here'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = []

# Application definition
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'bookshelf',
    'relationship_app',
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

ROOT_URLCONF = 'LibraryProject.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
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

WSGI_APPLICATION = 'LibraryProject.wsgi.application'

# Database
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# Static files (CSS, JavaScript, Images)
STATIC_URL = 'static/'

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Media files
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'
EOF
fi

# Add or update AUTH_USER_MODEL setting
if grep -q "AUTH_USER_MODEL" "$SETTINGS_FILE"; then
    # Replace existing AUTH_USER_MODEL
    sed -i "s/^AUTH_USER_MODEL.*/AUTH_USER_MODEL = 'bookshelf.CustomUser'/" "$SETTINGS_FILE"
    echo -e "${GREEN}✅ Updated AUTH_USER_MODEL in settings.py${NC}"
else
    # Add AUTH_USER_MODEL at the end of the file
    echo "" >> "$SETTINGS_FILE"
    echo "# Custom User Model" >> "$SETTINGS_FILE"
    echo "AUTH_USER_MODEL = 'bookshelf.CustomUser'" >> "$SETTINGS_FILE"
    echo -e "${GREEN}✅ Added AUTH_USER_MODEL to settings.py${NC}"
fi

# Ensure MEDIA settings are present
if ! grep -q "MEDIA_URL" "$SETTINGS_FILE"; then
    echo "" >> "$SETTINGS_FILE"
    echo "# Media files" >> "$SETTINGS_FILE"
    echo "MEDIA_URL = '/media/'" >> "$SETTINGS_FILE"
    echo "MEDIA_ROOT = BASE_DIR / 'media'" >> "$SETTINGS_FILE"
    echo -e "${GREEN}✅ Added MEDIA settings to settings.py${NC}"
fi

# Step 4: Update relationship_app models to use custom user
echo -e "${BLUE}Step 4: Updating relationship_app models...${NC}"

if [ -f "relationship_app/models.py" ]; then
    cp "relationship_app/models.py" "relationship_app/models.py.backup"
    echo -e "${GREEN}✅ Backed up relationship_app/models.py${NC}"
    
    # Update foreign key references to use the custom user model
    sed -i 's/from django.contrib.auth.models import User/from django.contrib.auth import get_user_model/' "relationship_app/models.py"
    sed -i 's/models.ForeignKey(User,/models.ForeignKey(get_user_model(),/' "relationship_app/models.py"
    echo -e "${GREEN}✅ Updated relationship_app models to use custom user${NC}"
fi

# Step 5: Create URLs configuration for media files
echo -e "${BLUE}Step 5: Updating URL configuration...${NC}"

URLS_FILE="LibraryProject/urls.py"

# Create or update main URLs file
if [ ! -f "$URLS_FILE" ]; then
    cat > "$URLS_FILE" << 'EOF'
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('bookshelf.urls')),
    path('relationship/', include('relationship_app.urls')),
]

# Serve media files during development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
EOF
    echo -e "${GREEN}✅ Created main URLs configuration${NC}"
else
    # Check if media files serving is already configured
    if ! grep -q "static(settings.MEDIA_URL" "$URLS_FILE"; then
        # Add media files configuration
        echo "" >> "$URLS_FILE"
        echo "# Serve media files during development" >> "$URLS_FILE"
        echo "from django.conf import settings" >> "$URLS_FILE"
        echo "from django.conf.urls.static import static" >> "$URLS_FILE"
        echo "" >> "$URLS_FILE"
        echo "if settings.DEBUG:" >> "$URLS_FILE"
        echo "    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)" >> "$URLS_FILE"
        echo -e "${GREEN}✅ Added media files serving to URLs${NC}"
    fi
fi

# Step 6: Create requirements.txt if it doesn't exist
echo -e "${BLUE}Step 6: Creating requirements.txt...${NC}"

if [ ! -f "requirements.txt" ]; then
    cat > "requirements.txt" << 'EOF'
Django>=4.2,<5.0
Pillow>=9.0.0
EOF
    echo -e "${GREEN}✅ Created requirements.txt with Django and Pillow${NC}"
fi

# Step 7: Create media directory
echo -e "${BLUE}Step 7: Creating media directory...${NC}"
mkdir -p "media/profile_photos"
echo -e "${GREEN}✅ Created media directories${NC}"

# Step 8: Create migration instructions
echo -e "${BLUE}Step 8: Creating migration instructions...${NC}"

cat > "MIGRATION_INSTRUCTIONS.md" << 'EOF'
# Django Custom User Model Migration Instructions

After running this script, you need to perform the following steps:

## 1. Install Required Packages
```bash
pip install -r requirements.txt
```

## 2. Create and Run Migrations
```bash
# Remove existing migrations (if this is a fresh setup)
rm -rf bookshelf/migrations/
rm -rf relationship_app/migrations/

# Create new migrations
python manage.py makemigrations bookshelf
python manage.py makemigrations relationship_app
python manage.py makemigrations

# Apply migrations
python manage.py migrate
```

## 3. Create Superuser
```bash
python manage.py createsuperuser
```

## 4. Run Development Server
```bash
python manage.py runserver
```

## 5. Access Admin Interface
Visit http://127.0.0.1:8000/admin/ and log in with your superuser credentials.

## Notes:
- The custom user model includes `date_of_birth` and `profile_photo` fields
- Profile photos will be uploaded to `media/profile_photos/`
- All existing user references have been updated to use the custom user model
- The admin interface has been configured to manage the custom user fields

## Troubleshooting:
If you encounter migration issues, you may need to:
1. Delete the database file (`db.sqlite3`)
2. Remove all migration files
3. Run the migration commands again
EOF

echo -e "${GREEN}✅ Created migration instructions${NC}"

# Summary
echo ""
echo -e "${GREEN}🎉 Custom User Model Setup Complete!${NC}"
echo "============================================"
echo -e "${BLUE}Files modified/created:${NC}"
echo "  ✅ bookshelf/models.py - Custom user model with date_of_birth and profile_photo"
echo "  ✅ bookshelf/admin.py - Admin interface for custom user model"
echo "  ✅ LibraryProject/settings.py - Updated AUTH_USER_MODEL setting"
echo "  ✅ relationship_app/models.py - Updated to use custom user model"
echo "  ✅ LibraryProject/urls.py - Added media files serving"
echo "  ✅ requirements.txt - Added Django and Pillow dependencies"
echo "  ✅ media/profile_photos/ - Directory for profile photos"
echo "  ✅ MIGRATION_INSTRUCTIONS.md - Step-by-step migration guide"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Read MIGRATION_INSTRUCTIONS.md for next steps!${NC}"
echo ""
echo -e "${BLUE}Key Features Added:${NC}"
echo "  🔸 CustomUser model extending AbstractUser"
echo "  🔸 date_of_birth field (DateField)"
echo "  🔸 profile_photo field (ImageField)"
echo "  🔸 Custom user manager with create_user and create_superuser methods"
echo "  🔸 Admin interface configured for new fields"
echo "  🔸 All user model references updated"
echo ""
echo -e "${GREEN}Next: Follow the migration instructions to complete the setup!${NC}"
