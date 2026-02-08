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

# Remove old Node.js
RUN apt-get remove -y nodejs libnode-dev nodejs-doc || true
RUN apt-get purge -y nodejs libnode-dev nodejs-doc || true
RUN apt-get autoremove -y

# Install Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs

# Install Yarn
RUN npm install -g yarn

# Set Python 3.11 default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Install bench + postgres driver
RUN pip3 install frappe-bench psycopg2-binary

# Create frappe user
RUN useradd -ms /bin/bash frappe

USER frappe
WORKDIR /home/frappe

# Copy apps.json
COPY development/apps.json /home/frappe/apps.json

# Initialize bench AND install apps from apps.json
RUN bench init frappe-bench \
    --frappe-branch version-15 \
    --python python3.11 \
    --apps_path /home/frappe/apps.json

WORKDIR /home/frappe/frappe-bench

EXPOSE 8000

CMD ["bench", "start"]
