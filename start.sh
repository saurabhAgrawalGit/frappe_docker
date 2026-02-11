#!/bin/bash

echo "Starting services..."

service cron start
redis-server --daemonize yes

cd /home/frappe/frappe-bench

SITE=${SITE_NAME:-site1.local}

echo "Using site: $SITE"

# Create site only if not exists
if [ ! -f "sites/$SITE/site_config.json" ]; then

    echo "Creating new site with PostgreSQL..."

    bench new-site $SITE \
        --db-type postgres \
        --db-host "$DB_HOST" \
        --db-port "$DB_PORT" \
        --db-name "$DB_NAME" \
        --db-user "$DB_USER" \
        --db-password "$DB_PASSWORD" \
        --admin-password "${ADMIN_PASSWORD:-admin}" \
        --no-mariadb-socket

    bench use $SITE

    bench migrate
fi

# Force use correct site
bench use $SITE

# IMPORTANT FIX: overwrite config to ensure correct host
bench set-config -g db_host "$DB_HOST"
bench set-config -g db_port "$DB_PORT"

echo "Starting bench..."

bench start --port ${PORT:-8000}
