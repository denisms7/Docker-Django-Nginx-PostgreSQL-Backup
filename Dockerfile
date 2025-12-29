FROM python:3.13.6-slim-bullseye AS base

LABEL mantainer="https://github.com/denisms7"

# Essa variável de ambiente é usada para controlar se o Python deve
# gravar arquivos de bytecode (.pyc) no disco. 1 = Não, 0 = Sim
ENV PYTHONDONTWRITEBYTECODE 1

# Define que a saída do Python será exibida imediatamente no console ou em
# outros dispositivos de saída, sem ser armazenada em buffer.
# Em resumo, você verá os outputs do Python em tempo real. 1 = Não, 0 = Sim
ENV PYTHONUNBUFFERED 1

ENV LANG C.UTF-8

# Entra na pasta no container
WORKDIR /app

RUN pip install --upgrade pip

COPY ./requirements.txt ./

RUN apt-get update && apt-get install -y \
    # Libs para criação de PDF:
    libpango-1.0-0 \
    libpango1.0-dev \
    libcairo2 \
    libcairo2-dev \
    libgdk-pixbuf2.0-0 \
    libffi-dev \
    libxml2 \
    libxml2-dev \
    libxslt1-dev \
    libssl-dev \
    # Libs para o sistema:
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    curl \
    libpq-dev && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get remove -y gcc pkg-config && \
    rm -rf /var/lib/apt/lists/*


COPY . .

# A porta 8000 estará disponível para conexões externas ao container
# É a porta que vamos usar para o Django.
EXPOSE 8000
