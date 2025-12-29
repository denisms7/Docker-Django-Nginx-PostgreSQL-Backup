FROM postgres:17.5

RUN apt-get update && apt-get install -y bash cron tzdata curl procps \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /backup

COPY entrypoint.sh /entrypoint.sh
COPY backup.sh /backup/backup.sh

RUN chmod +x /backup/backup.sh && \
    chmod +x /entrypoint.sh && \
    mkdir -p /backup/output && \
    touch /backup/backup.log && \
    chmod 666 /backup/backup.log

ENV TZ=America/Sao_Paulo

ENTRYPOINT ["/entrypoint.sh"]