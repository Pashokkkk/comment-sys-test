from django.contrib import admin
from django.urls import path, include, re_path
from django.views.generic import TemplateView
from django.conf import settings
from django.conf.urls.static import static
from django.views.decorators.cache import never_cache
import logging

from comments.views import UserCommentListCreateAPIView
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

# -------------------------------
# Main URL Configuration
# -------------------------------

urlpatterns = [
    path('admin/', admin.site.urls),  # Django admin panel
    path('api/', include('comments.urls')),  # Comment-related API endpoints
    path('api/comments/', UserCommentListCreateAPIView.as_view()),  # List/create comments
    path('captcha/', include('captcha.urls')),  # CAPTCHA image endpoint
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),  # JWT login
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),  # JWT refresh
]

# Enable debug logging
logging.basicConfig(level=logging.DEBUG)

# Serve media files (e.g. uploaded images) in development
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

# Fallback to index.html for all other routes (for Vue SPA)
urlpatterns += [
    re_path(r'^.*$', never_cache(TemplateView.as_view(template_name='index.html'))),
]
