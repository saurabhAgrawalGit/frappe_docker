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
    npm \
    && rm -rf /var/lib/apt/lists/*

# Remove old Node.js if exists
RUN apt-get remove -y nodejs libnode-dev nodejs-doc || true
RUN apt-get purge -y nodejs libnode-dev nodejs-doc || true
RUN apt-get autoremove -y

# Install Node.js 18 (required for Frappe v15)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs

# Install Yarn
RUN npm install -g yarn

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Install bench and PostgreSQL driver
RUN pip3 install frappe-bench psycopg2-binary

# Create frappe user
RUN useradd -ms /bin/bash frappe

USER frappe
WORKDIR /home/frappe

# Copy apps.json file
COPY development/apps.json /home/frappe/apps.json

# Initialize bench with Python 3.11
RUN bench init frappe-bench --frappe-branch version-15 --python python3.11

WORKDIR /home/frappe/frappe-bench

# Install your custom app
RUN bench get-app --apps_path /home/frappe/apps.json

# Expose port
EXPOSE 8000

# Start frappe
CMD ["bench", "start"]
