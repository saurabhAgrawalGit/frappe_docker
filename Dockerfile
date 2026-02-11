FROM python:3.11.9-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies required for Frappe v16
RUN apt-get update && apt-get install -y \
    git \
    curl \
    gcc \
    g++ \
    make \
    build-essential \
    redis-server \
    postgresql-client \
    libpq-dev \
    pkg-config \
    libmariadb-dev \
    libmariadb-dev-compat \
    libffi-dev \
    libssl-dev \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Node 24 (REQUIRED for frappe v16)
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs

# Install yarn
RUN npm install -g yarn

# Install bench and postgres driver
RUN pip install --no-cache-dir --upgrade pip setuptools wheel
RUN pip install --no-cache-dir frappe-bench psycopg2-binary

# Create frappe user
RUN useradd -ms /bin/bash frappe

USER frappe
WORKDIR /home/frappe

# Verify python version
RUN python --version

# Initialize bench (THIS WILL NOW WORK)
RUN bench init frappe-bench \
    --frappe-branch version-16 \
    --python python

WORKDIR /home/frappe/frappe-bench

# Install your custom app
RUN bench get-app leave_management https://github.com/saurabhAgrawalGit/leave_management || true

# Copy startup script
COPY --chown=frappe:frappe start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8000

CMD ["/start.sh"]
