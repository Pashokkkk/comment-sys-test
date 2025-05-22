#!/bin/bash
# entrypoint.sh — запуск Django проєкту на Render

# Зупинити скрипт при помилці
set -e

echo "🚀 ENTRYPOINT: запуск почато" >&2

echo "📦 Збір статичних файлів..."
python manage.py collectstatic --noinput

echo "🛠 Застосування міграцій..."
python manage.py migrate --noinput

echo "👤 Створення суперкористувача (якщо його ще немає)..."
python manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username="root").exists():
    User.objects.create_superuser("root", "root@example.com", "root")
    print("✅ Суперкористувача 'root' створено")
else:
    print("ℹ️ Суперкористувач 'root' вже існує")
END

echo "🚀 Запуск сервера Gunicorn + Uvicorn..."
exec daphne -b 0.0.0.0 -p 8000 config.asgi:application
