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
    mariadb-client \
    libpq-dev \
    gcc \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs

# Install Yarn
RUN npm install -g yarn

# Set python3.11 default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Install bench
RUN pip3 install frappe-bench

# Create frappe user
RUN useradd -ms /bin/bash frappe

USER frappe
WORKDIR /home/frappe

# Copy apps.json
COPY development/apps.json /home/frappe/apps.json

# Initialize bench
RUN bench init frappe-bench --frappe-branch version-15 --python python3.11

WORKDIR /home/frappe/frappe-bench

# Install apps
RUN bench get-app --apps_path /home/frappe/apps.json

EXPOSE 8000

CMD ["bench", "start"]
