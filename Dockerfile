FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    git \
    curl \
    redis-server \
    nodejs \
    npm \
    mariadb-client \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Set python3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Install bench
RUN pip3 install frappe-bench

# Create frappe user
RUN useradd -ms /bin/bash frappe

USER frappe
WORKDIR /home/frappe

# Copy apps.json
COPY development/apps.json /home/frappe/apps.json

# Initialize bench using Python 3.11
RUN bench init frappe-bench --frappe-branch version-15 --python python3.11

WORKDIR /home/frappe/frappe-bench

# Install your app
RUN bench get-app --apps_path /home/frappe/apps.json

EXPOSE 8000

CMD ["bench", "start"]
