# 1. Етап: білд фронтенду (Vue)
FROM node:18 AS frontend

WORKDIR /frontend

COPY frontend/package*.json ./
RUN npm install

COPY frontend/ ./
RUN npm run build

# 2. Етап: білд бекенду (Django)
FROM python:3.10

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

# Встановлюємо залежності
COPY requirements.txt /app/
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Копіюємо Django проєкт
COPY backend/ /app/

# Копіюємо зібраний frontend у Django-проєкт (наприклад у папку frontend/dist)
# COPY --from=frontend /frontend/dist /app/frontend/dist
COPY --from=frontend /frontend_dist /app/frontend_dist

# Команда collectstatic після вставки фронтенду
RUN python manage.py collectstatic --noinput


# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

RUN cat /app/entrypoint_log.txt || echo "🚫 ENTRYPOINT LOG NOT WRITTEN"

