from django.urls import path
from .views import captcha_refresh, UserCommentListCreateAPIView, welcome_api

urlpatterns = [
    path('', welcome_api),
    path('comments/', UserCommentListCreateAPIView.as_view(), name='comment-list-create'),
    path('captcha/refresh/', captcha_refresh),
]
