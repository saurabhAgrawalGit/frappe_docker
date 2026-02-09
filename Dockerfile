FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies required by frappe v16
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip \
    git \
    curl \
    redis-server \
    postgresql-client \
    libpq-dev \
    gcc \
    g++ \
    build-essential \
    cron \
    pkg-config \
    libffi-dev \
    libssl-dev \
    libjpeg-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    tk-dev \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# Install Yarn
RUN npm install -g yarn

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Upgrade pip and install frappe-bench
RUN pip3 install --upgrade pip setuptools wheel
RUN pip3 install frappe-bench psycopg2-binary

# Create frappe user
RUN useradd -ms /bin/bash frappe

USER frappe
WORKDIR /home/frappe

# Copy apps.json
COPY development/apps.json /home/frappe/apps.json

# Initialize bench (Frappe v16)
RUN bench init frappe-bench \
    --frappe-branch version-16 \
    --python python3.11 \
    --apps_path /home/frappe/apps.json

# Switch to bench directory
WORKDIR /home/frappe/frappe-bench

# Build frontend assets (required for Doppio)
RUN bench build

# Copy startup script
COPY start.sh /home/frappe/start.sh

USER root
RUN chmod +x /home/frappe/start.sh
USER frappe

EXPOSE 8000

CMD ["/home/frappe/start.sh"]
