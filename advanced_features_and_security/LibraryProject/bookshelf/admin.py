from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.utils.translation import gettext_lazy as _
from .models import CustomUser, Book


class CustomUserAdmin(UserAdmin):
    """
    Custom user admin that includes the additional fields
    """

    # Fields to display in the admin list view
    list_display = (
        "username",
        "email",
        "first_name",
        "last_name",
        "date_of_birth",
        "is_staff",
        "is_active",
    )

    # Fields that can be searched
    search_fields = ("username", "first_name", "last_name", "email")

    # Filters for the right sidebar
    list_filter = (
        "is_staff",
        "is_superuser",
        "is_active",
        "date_joined",
        "date_of_birth",
    )

    # Fields to display when editing a user
    fieldsets = UserAdmin.fieldsets + (
        (
            _("Additional Information"),
            {
                "fields": ("date_of_birth", "profile_photo"),
                "classes": ("collapse",),  # Make this section collapsible
            },
        ),
    )

    # Fields to display when creating a new user
    add_fieldsets = UserAdmin.add_fieldsets + (
        (
            _("Additional Information"),
            {
                "fields": ("date_of_birth", "profile_photo"),
                "classes": ("collapse",),
            },
        ),
    )

    # Read-only fields
    readonly_fields = ("date_joined", "last_login")

    # Ordering
    ordering = ("username",)


@admin.register(Book)
class BookAdmin(admin.ModelAdmin):
    """
    Admin configuration for Book model
    """

    list_display = ("title", "author", "publication_year")
    list_filter = ("publication_year", "author")
    search_fields = ("title", "author")
    ordering = ("title",)


# Register CustomUser with CustomUserAdmin using the traditional method
admin.site.register(CustomUser, CustomUserAdmin)
