#!/bin/bash
# entrypoint.sh

# Зупини виконання при помилці
set -e

# Збираємо статику
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Міграції (опціонально)
echo "Applying database migrations..."
python manage.py migrate

# Запускаємо сервер (наприклад daphne або gunicorn)
echo "Starting server..."
exec gunicorn config.asgi:application -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
