from rest_framework import generics, filters
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from rest_framework_simplejwt.authentication import JWTAuthentication

from captcha.models import CaptchaStore
from captcha.helpers import captcha_image_url

from django.contrib.auth.models import User
from django_filters.rest_framework import DjangoFilterBackend

from .models import UserComment
from .serializers import UserCommentSerializer

import redis


@api_view(['GET'])
def captcha_refresh(request):
    """
    Refresh CAPTCHA: return new key and image URL.
    """
    new_key = CaptchaStore.generate_key()
    image_url = captcha_image_url(new_key)
    return Response({'key': new_key, 'image_url': image_url})


@api_view(['GET'])
def test_user(request):
    """
    Create a test superuser "root" if not exists.
    """
    if not User.objects.filter(username="root").exists():
        User.objects.create_superuser("root", "root@example.com", "root")
        return Response({"created": True})
    return Response({"exists": True})

def test_redis(request):
    r = redis.from_url(os.getenv("REDIS_URL"))
    try:
        r.set("test", "ok")
        return JsonResponse({"status": "connected"})
    except Exception as e:
        return JsonResponse({"error": str(e)})

class UserCommentListCreateAPIView(generics.ListCreateAPIView):
    """
    List and create top-level comments (no parent).
    Only authenticated users can POST.
    """
    queryset = UserComment.objects.filter(parent_comment__isnull=True)
    serializer_class = UserCommentSerializer
    parser_classes = [MultiPartParser, FormParser]
    permission_classes = [IsAuthenticatedOrReadOnly]
    authentication_classes = [JWTAuthentication]
    filter_backends = [filters.OrderingFilter, DjangoFilterBackend]
    ordering_fields = ['username', 'email', 'created_at']
    ordering = ['-created_at']
