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

echo "👤 Creating superuser if it doesn't exist..."
python manage.py shell << END
from django.contrib.auth.models import User
if not User.objects.filter(username="root").exists():
    User.objects.create_superuser("root", "root@example.com", "root")
    print("✅ Superuser 'root' created.")
else:
    print("ℹ️ Superuser 'root' already exists.")
END

# Запускаємо сервер (наприклад daphne або gunicorn)
echo "Starting server..."
exec gunicorn config.asgi:application -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
