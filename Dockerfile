# backend/Dockerfile
# FROM python:3.10

# ENV PYTHONDONTWRITEBYTECODE 1
# ENV PYTHONUNBUFFERED 1

# WORKDIR /app

# COPY requirements.txt /app/
# RUN pip install --upgrade pip
# RUN pip install -r requirements.txt

# COPY backend/ /app/
# RUN python manage.py collectstatic --noinput


# Stage 1: Build frontend (Vue)
FROM node:18 AS frontend-build
WORKDIR /app/frontend
COPY frontend/ ./  
RUN npm install
RUN npm run build

# Stage 2: Django backend with Python
FROM python:3.10

# Environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy backend code
COPY backend/ backend/
COPY backend/manage.py .

# Copy frontend build into backend
COPY --from=frontend-build /app/frontend/dist/index.html backend/templates/index.html
COPY --from=frontend-build /app/frontend/dist/assets/ backend/static/assets/

# Run collectstatic
RUN python manage.py collectstatic --noinput

# Expose port (for Render)
EXPOSE 8000

# Start ASGI server
CMD ["daphne", "-b", "0.0.0.0", "-p", "8000", "config.asgi:application"]
