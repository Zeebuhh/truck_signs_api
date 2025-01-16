#!/usr/bin/env bash
set -e

echo "Waiting for postgres to connect..."

while ! nc -z $DB_HOST $DB_PORT; do
  sleep 0.1
done

echo "PostgreSQL is active"

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Running migrations..."
if [ "$DJANGO_ENV" = "development" ]; then
  echo "Running makemigrations in development mode..."
  python manage.py makemigrations
fi
python manage.py migrate

if [ "$DJANGO_SUPERUSER_USERNAME" ] && [ "$DJANGO_SUPERUSER_EMAIL" ] && [ "$DJANGO_SUPERUSER_PASSWORD" ]; then
    echo "Creating superuser..."
    python manage.py createsuperuser \
        --noinput \
        --username $DJANGO_SUPERUSER_USERNAME \
        --email $DJANGO_SUPERUSER_EMAIL || echo "Superuser already exists or creation failed."
fi

echo "Postgresql migrations finished. Starting Gunicorn..."
gunicorn truck_signs_designs.wsgi:application --bind 0.0.0.0:8020