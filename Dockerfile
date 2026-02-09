FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/home/frappe/.local/bin:${PATH}"

# --------------------------------------------------
# Install system dependencies
# --------------------------------------------------
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    git \
    redis-server \
    postgresql-client \
    libpq-dev \
    gcc \
    cron \
    pkg-config \
    build-essential \
    libffi-dev \
    libssl-dev \
    libmariadb-dev \
    && rm -rf /var/lib/apt/lists/*


# --------------------------------------------------
# Install stable Python 3.11 from deadsnakes
# --------------------------------------------------
RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip


# Set python3.11 default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1


# --------------------------------------------------
# Install Node.js 20
# --------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs


# --------------------------------------------------
# Install Yarn
# --------------------------------------------------
RUN npm install -g yarn


# --------------------------------------------------
# Install bench
# --------------------------------------------------
RUN pip3 install --no-cache-dir frappe-bench psycopg2-binary


# --------------------------------------------------
# Create frappe user
# --------------------------------------------------
RUN useradd -ms /bin/bash frappe


USER frappe
WORKDIR /home/frappe


# --------------------------------------------------
# Copy apps.json
# --------------------------------------------------
COPY development/apps.json /home/frappe/apps.json


# --------------------------------------------------
# Initialize bench
# --------------------------------------------------
RUN bench init frappe-bench \
    --frappe-branch version-16 \
    --python python3.11 \
    --apps_path /home/frappe/apps.json


WORKDIR /home/frappe/frappe-bench


# --------------------------------------------------
# Start script
# --------------------------------------------------
COPY start.sh /home/frappe/start.sh

USER root
RUN chmod +x /home/frappe/start.sh
RUN chown frappe:frappe /home/frappe/start.sh

USER frappe


EXPOSE 8000

CMD ["/home/frappe/start.sh"]
