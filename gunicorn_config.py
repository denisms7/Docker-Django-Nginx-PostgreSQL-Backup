bind = "0.0.0.0:8000"
# Define o endereço IP e a porta em que o Gunicorn vai escutar.
# "0.0.0.0" significa que aceita conexões de qualquer IP, e "8000" é a porta.

workers = 4
# Define o número de processos worker do Gunicorn.
# Cada worker lida com requisições separadamente, aumentando a capacidade de atender múltiplas requisições simultâneas.
# Normalmente, a recomendação é (2 x número de CPUs) + 1.

worker_connections = 1000  # conexões máximas por worker
# Número máximo de conexões simultâneas que cada worker pode abrir.
# Relevante principalmente para workers do tipo async (como gevent ou eventlet).

threads = 4  # Uso da CPU
# Define quantas threads cada worker vai usar para processar requisições.
# Aumenta a paralelização dentro de um mesmo worker, útil para requisições I/O bound.

timeout = 120  # opcional, aumenta tempo para requisições longas
# Tempo máximo, em segundos, que um worker vai esperar por uma requisição antes de ser reiniciado.
# Útil se você tem operações que podem demorar mais que o padrão (30s).
