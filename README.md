# 📝 Comment System (Deployed: Django + Vue + JWT + WebSocket + Docker)

A fully deployed comment system with nested replies, JWT authentication, CAPTCHA, image/file uploads, live updates via WebSocket, and SPA frontend powered by Vue.js.

---

## 🔗 Access:

| Service         | URL                                             |
|------------------|--------------------------------------------------|
| 🎨 Frontend SPA  | [https://comment-sys-test.onrender.com) |
| ⚙ Django Admin   | [https://comment-sys-test.onrender.com/admin/) |

---

## 🔐 JWT Login (for authenticated commenting)

```http
POST https://comment-sys-test.onrender.com/api/token/
Content-Type: application/json

{
  "username": "root",
  "password": "root"
}
```

Response:

```json
{
  "refresh": "<...>",
  "access": "<...>"
}
```

Add this to requests:

```
Authorization: Bearer <access_token>
```

---

## 🔧 Features implemented:

- 💬 Top-level and nested replies
- 🔐 JWT auth with token refresh (auto handled in frontend)
- 🧠 CAPTCHA verification with refresh
- 🖼 File uploads: .jpg, .png, .txt, .md
- ✅ Comment preview before submission
- ✅ Safe HTML tags: `<i>`, `<strong>`, `<code>`, `<a>`
- ⚠️ HTML validation: only closed tags allowed
- 📎 Pagination, sorting, and filters
- ✨ Real-time updates via WebSocket (no reload!)
- ✅ Responsive SPA with Vue 3
- 📦 Dockerized backend + frontend
- 📂 Media files persist correctly across deploys (via media/ volume)

---

## 🛠 Stack
- Backend: Django + Django REST + Channels
- Frontend: Vue 3 (Vite)
- Auth: JWT (SimpleJWT)
- Real-time: WebSocket (Channels)
- Queueing: Celery + Redis
- Deployment: Render.com
- CAPTCHA: django-simple-captcha
- Others: Docker, Lightbox, Tailwind/Bootstrap (if any)🔎 WebSocket check

---

## ⚙ Deployment Notes
- Media files persist in media/ and are served from Django via MEDIA_URL.
- Redis is hosted via Redis Cloud and configured via the REDIS_URL env var.
- JWT tokens auto-refresh when expired.
- Static files are bundled into the Vue build and served via WhiteNoise.
- WebSocket traffic handled via Daphne server.

---

## ❓ Troubleshooting
- Token Expired: You’ll see Given token not valid for any token type – please log in again.

- CAPTCHA not matching: Ensure correct key-text pair, or refresh the CAPTCHA.

- Media not saving: Confirm media/ directory is writeable and not excluded by .dockerignore.


