from django.core.management.base import BaseCommand
from django.contrib.auth.models import Group, Permission
from django.contrib.contenttypes.models import ContentType
from bookshelf.models import Book, Library

class Command(BaseCommand):
    help = 'Create user groups and assign permissions'

    def handle(self, *args, **options):
        # Create groups
        editors_group, created = Group.objects.get_or_create(name='Editors')
        viewers_group, created = Group.objects.get_or_create(name='Viewers')
        admins_group, created = Group.objects.get_or_create(name='Admins')

        # Get content types
        book_content_type = ContentType.objects.get_for_model(Book)
        library_content_type = ContentType.objects.get_for_model(Library)

        # Get or create permissions
        can_view_book, _ = Permission.objects.get_or_create(
            codename='can_view',
            name='Can view book',
            content_type=book_content_type,
        )
        can_create_book, _ = Permission.objects.get_or_create(
            codename='can_create',
            name='Can create book',
            content_type=book_content_type,
        )
        can_edit_book, _ = Permission.objects.get_or_create(
            codename='can_edit',
            name='Can edit book',
            content_type=book_content_type,
        )
        can_delete_book, _ = Permission.objects.get_or_create(
            codename='can_delete',
            name='Can delete book',
            content_type=book_content_type,
        )
        can_add_book_to_library, _ = Permission.objects.get_or_create(
            codename='can_add_book',
            name='Can add book to library',
            content_type=library_content_type,
        )
        can_remove_book_from_library, _ = Permission.objects.get_or_create(
            codename='can_remove_book',
            name='Can remove book from library',
            content_type=library_content_type,
        )

        # Assign permissions to groups
        # Viewers: can only view
        viewers_group.permissions.clear()
        viewers_group.permissions.add(can_view_book)

        # Editors: can view, create, and edit (but not delete)
        editors_group.permissions.clear()
        editors_group.permissions.add(can_view_book, can_create_book, can_edit_book)
        editors_group.permissions.add(can_add_book_to_library, can_remove_book_from_library)

        # Admins: can do everything
        admins_group.permissions.clear()
        admins_group.permissions.add(
            can_view_book, can_create_book, can_edit_book, can_delete_book,
            can_add_book_to_library, can_remove_book_from_library
        )

        self.stdout.write(
            self.style.SUCCESS(
                'Successfully created groups and assigned permissions:\n'
                '- Viewers: can_view\n'
                '- Editors: can_view, can_create, can_edit, can_add_book, can_remove_book\n'
                '- Admins: all permissions'
            )
        )
