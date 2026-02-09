FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies (FIXED)
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    git \
    curl \
    redis-server \
    postgresql-client \
    libpq-dev \
    gcc \
    cron \
    build-essential \
    pkg-config \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# Install Yarn
RUN npm install -g yarn

# Set Python 3.11 default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Install bench and postgres driver
RUN pip3 install frappe-bench psycopg2-binary

# Create frappe user
RUN useradd -ms /bin/bash frappe

USER frappe
WORKDIR /home/frappe

COPY development/apps.json /home/frappe/apps.json

RUN bench init frappe-bench \
    --frappe-branch version-16 \
    --python python3.11 \
    --apps_path /home/frappe/apps.json

WORKDIR /home/frappe/frappe-bench

RUN bench build

COPY start.sh /home/frappe/start.sh

USER root
RUN chmod +x /home/frappe/start.sh
USER frappe

EXPOSE 8000

CMD ["/home/frappe/start.sh"]
