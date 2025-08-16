# LibraryProject

A Django web application project for managing a library system.

## Setup Instructions

### Prerequisites
- Python 3.x installed
- Virtual environment activated

### Installation
1. Ensure you're in the virtual environment:
   ```bash
   source ../django_env/bin/activate  # On Unix/Linux/MacOS
   # OR
   ..\django_env\Scripts\activate     # On Windows
   ```

2. Install dependencies (if any):
   ```bash
   pip install -r requirements.txt
   ```

### Running the Development Server
```bash
python manage.py runserver
```

Then open your browser and go to: `http://127.0.0.1:8000/`

### Project Structure
- `manage.py`: Command-line utility for interacting with the Django project
- `LibraryProject/settings.py`: Configuration settings for the Django project
- `LibraryProject/urls.py`: URL routing configuration
- `LibraryProject/wsgi.py`: WSGI configuration for deployment
- `LibraryProject/asgi.py`: ASGI configuration for async support

### Useful Commands
- `python manage.py runserver`: Start the development server
- `python manage.py migrate`: Apply database migrations
- `python manage.py createsuperuser`: Create an admin user
- `python manage.py startapp <app_name>`: Create a new Django app
- `python manage.py collectstatic`: Collect static files for production

### Development Workflow
1. Make changes to your code
2. Run migrations if you've changed models: `python manage.py makemigrations` then `python manage.py migrate`
3. Test your changes with `python manage.py runserver`

## Next Steps
- Create Django applications using `python manage.py startapp <app_name>`
- Configure your database settings in `settings.py`
- Create models, views, and templates for your library system
