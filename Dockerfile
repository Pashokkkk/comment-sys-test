# Stage 1: Vue frontend
FROM node:18 AS frontend-build

WORKDIR /app
COPY frontend/ ./frontend
WORKDIR /app/frontend
RUN npm install && npm run build

# Stage 2: Django
FROM python:3.10

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PYTHONPATH=/app/backend

WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

COPY backend/ backend/
COPY backend/manage.py .

# ← важливо! index.html і assets вже тут
COPY --from=frontend-build /app/backend/static/ backend/static/

RUN python manage.py collectstatic --noinput

EXPOSE 8000
CMD ["daphne", "-b", "0.0.0.0", "-p", "8000", "config.asgi:application"]
