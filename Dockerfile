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
    postgresql-client \
    libpq-dev \
    gcc \
    cron \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Remove old Node.js if exists
RUN apt-get remove -y nodejs libnode-dev nodejs-doc || true
RUN apt-get purge -y nodejs libnode-dev nodejs-doc || true
RUN apt-get autoremove -y

# Install Node.js 20 (required for React / Doppio)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# Install Yarn globally
RUN npm install -g yarn

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Install bench and PostgreSQL driver
RUN pip3 install frappe-bench psycopg2-binary

# Create frappe user
RUN useradd -ms /bin/bash frappe

USER frappe
WORKDIR /home/frappe

# Copy apps.json
COPY development/apps.json /home/frappe/apps.json

# Initialize bench with Frappe v16
RUN bench init frappe-bench \
    --frappe-branch version-16 \
    --python python3.11 \
    --apps_path /home/frappe/apps.json

# Switch to bench directory
WORKDIR /home/frappe/frappe-bench

# Pass React environment variables for build
ENV REACT_APP_API_URL=$REACT_APP_API_URL
ENV REACT_APP_ENV=$REACT_APP_ENV
ENV REACT_APP_NAME=$REACT_APP_NAME

# Build frontend assets (important for Doppio)
RUN bench build

# Copy startup script
COPY start.sh /home/frappe/start.sh

# Give permission
USER root
RUN chmod +x /home/frappe/start.sh
USER frappe

# Expose port (Railway will override with $PORT)
EXPOSE 8000

# Start frappe
CMD ["/home/frappe/start.sh"]
