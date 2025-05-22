#!/bin/bash
set -e

echo "📦 Collecting static..."
python manage.py collectstatic --noinput

echo "🛠 Applying migrations..."
python manage.py migrate --noinput

echo "👤 Creating superuser if not exists..."
python manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username="root").exists():
    User.objects.create_superuser("root", "root@example.com", "root")
    print("✅ Superuser created")
END

echo "🚀 Starting Daphne server..."
exec daphne -b 0.0.0.0 -p 8000 config.asgi:application
