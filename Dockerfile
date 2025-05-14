# ========================
# Stage 1: Build frontend
# ========================
FROM node:18 AS frontend-build

# Робоча директорія
WORKDIR /app

# Копіюємо всю папку frontend
COPY frontend/ ./frontend

# Переходимо в неї
WORKDIR /app/frontend

# Встановлюємо залежності та білдимо
RUN npm install
RUN npm run build


# ========================
# Stage 2: Backend (Django)
# ========================
FROM python:3.10

# Env variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Робоча директорія
WORKDIR /app

# Встановлюємо Python-залежності
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Копіюємо backend код
COPY backend/ backend/
COPY backend/manage.py .

# Копіюємо фронтенд білд у Django шаблони та статичні файли
COPY --from=frontend-build /app/frontend/dist/index.html backend/templates/index.html
COPY --from=frontend-build /app/frontend/dist/assets/ backend/static/assets/

# Збір статичних файлів
RUN python manage.py collectstatic --noinput

# Порт, який слухає Render
EXPOSE 8000

# Запускаємо ASGI сервер
CMD ["daphne", "-b", "0.0.0.0", "-p", "8000", "config.asgi:application"]
