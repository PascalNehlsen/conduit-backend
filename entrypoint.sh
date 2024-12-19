#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if gunicorn is installed
if ! command -v gunicorn &> /dev/null
then
    echo "Gunicorn could not be found, installing it."
    pip install --user gunicorn
fi

# collect static files
echo "collect static files..."
python manage.py collectstatic --noinput

# Migrate database
echo "Running database migrations..."
python manage.py makemigrations || { echo "Makemigrations failed"; exit 1; }
python manage.py migrate || { echo "Migration failed"; exit 1; }

# Load superuser credentials from .env
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi;

# Validate superuser credentials
if [ -z "$DJANGO_SUPERUSER_USERNAME" ] || [ -z "$DJANGO_SUPERUSER_EMAIL" ] || [ -z "$DJANGO_SUPERUSER_PASSWORD" ]; then
  echo "Superuser data is not set. Please check the .env file."
  exit 1
fi;

echo "Creating superuser if not exists..."

# Check if superuser exists before attempting to create
python manage.py createsuperuser --noinput \
  --email "$DJANGO_SUPERUSER_EMAIL" \
  --username "$DJANGO_SUPERUSER_USERNAME"
###

# Start Django Server with gunicorn
echo "Starting the server with gunicorn..."
exec gunicorn conduit.wsgi:application --bind 0.0.0.0:8000 --worker-class gthread

