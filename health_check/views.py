from django.http import JsonResponse
from django.db import connection


def health_check(request):
    """
    Verifica se a aplicação e o banco de dados estão funcionando
    """
    try:
        # Testa conexão com banco de dados
        connection.ensure_connection()
        return JsonResponse({
            'status': 'healthy',
            'database': 'connected'
        }, status=200)
    except Exception as e:
        return JsonResponse({
            'status': 'unhealthy',
            'error': str(e)
        }, status=500)
