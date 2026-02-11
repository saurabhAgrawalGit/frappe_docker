#!/bin/bash

echo "Starting Frappe..."

service cron start
redis-server --daemonize yes

cd /home/frappe/frappe-bench

# Create site if not exists
if [ ! -d "sites/${SITE_NAME}" ]; then
    echo "Creating new site..."

    bench new-site ${SITE_NAME} \
        --db-type postgres \
        --db-host ${DB_HOST} \
        --db-port ${DB_PORT} \
        --db-name ${DB_NAME} \
        --db-user ${DB_USER} \
        --db-password ${DB_PASSWORD} \
        --admin-password ${ADMIN_PASSWORD} \
        --no-mariadb-socket

    bench use ${SITE_NAME}

    bench migrate
fi

bench use ${SITE_NAME}

echo "Starting bench..."

bench start --port ${PORT:-8000}
