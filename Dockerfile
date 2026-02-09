FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/home/frappe/.local/bin:${PATH}"

# --------------------------------------------------
# Install base dependencies
# --------------------------------------------------
RUN apt-get update && apt-get install -y \
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
    software-properties-common \
    wget \
    make \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

# --------------------------------------------------
# Install Python 3.11.9 manually (stable)
# --------------------------------------------------
WORKDIR /tmp

RUN wget https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tgz

RUN tar -xvf Python-3.11.9.tgz

WORKDIR /tmp/Python-3.11.9

RUN ./configure --enable-optimizations

RUN make -j$(nproc)

RUN make altinstall

# Set python3.11 as default
RUN ln -s /usr/local/bin/python3.11 /usr/bin/python3
RUN ln -s /usr/local/bin/pip3.11 /usr/bin/pip3

# Verify version
RUN python3 --version

# --------------------------------------------------
# Install Node.js 20
# --------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# Install Yarn
RUN npm install -g yarn

# --------------------------------------------------
# Install bench
# --------------------------------------------------
RUN pip3 install frappe-bench psycopg2-binary

# --------------------------------------------------
# Create frappe user
# --------------------------------------------------
RUN useradd -ms /bin/bash frappe

USER frappe
WORKDIR /home/frappe

# Copy apps.json
COPY development/apps.json /home/frappe/apps.json

# --------------------------------------------------
# Init bench (THIS WILL WORK NOW)
# --------------------------------------------------
RUN bench init frappe-bench \
    --frappe-branch version-16 \
    --python python3.11 \
    --apps_path /home/frappe/apps.json

WORKDIR /home/frappe/frappe-bench

COPY start.sh /home/frappe/start.sh

USER root
RUN chmod +x /home/frappe/start.sh
RUN chown frappe:frappe /home/frappe/start.sh

USER frappe

EXPOSE 8000

CMD ["/home/frappe/start.sh"]
