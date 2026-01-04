from django.urls import path
from . import views


urlpatterns = [
    path('health/db/', views.health_check, name='health_check'),
    # path('health/backup/', views.health_check, name='health_backup'),
]
