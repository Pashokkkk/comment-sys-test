# Stage 1: Build frontend (Vue)
FROM node:18 AS frontend-build

WORKDIR /app

# Копіюємо всю папку frontend
COPY frontend/ ./frontend

# Переходимо до папки frontend
WORKDIR /app/frontend

# Встановлюємо залежності та будуємо проєкт
RUN npm install
RUN npm run build

# Stage 2: Django backend with Python
FROM python:3.10

# Встановлюємо змінні середовища
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

# Встановлюємо Python-залежності
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Копіюємо код бекенду
COPY backend/ backend/
COPY backend/manage.py .

# Копіюємо static файли з фронтенду (vite вивів у backend/static/)
COPY --from=frontend-build /app/backend/static/ backend/static/

# Збираємо статичні файли
RUN python manage.py collectstatic --noinput

# Відкриваємо порт 8000
EXPOSE 8000

# Запускаємо ASGI сервер
CMD ["daphne", "-b", "0.0.0.0", "-p", "8000", "config.asgi:application"]
