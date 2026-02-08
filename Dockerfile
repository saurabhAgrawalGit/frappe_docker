FROM python:3.11-slim

USER root

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    redis-server \
    mariadb-client \
    libpq-dev \
    gcc \
    curl \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install bench
RUN pip install frappe-bench

# Create frappe user
RUN useradd -ms /bin/bash frappe

USER frappe

WORKDIR /home/frappe

# Copy apps.json
COPY development/apps.json /home/frappe/apps.json

# Initialize bench with correct Python version
RUN bench init frappe-bench --frappe-branch version-15 --python python3.11

WORKDIR /home/frappe/frappe-bench

# Install your app
RUN bench get-app --apps_path /home/frappe/apps.json

EXPOSE 8000

CMD ["bench", "start"]
