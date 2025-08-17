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
