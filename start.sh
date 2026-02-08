#!/bin/bash

cd /home/frappe/frappe-bench

SITE=$SITE_NAME

echo "Using Railway PORT: $PORT"

# Set correct port
bench set-config -g webserver_port $PORT

# Create site if not exists
if [ ! -d "sites/$SITE" ]; then
    echo "Creating PostgreSQL site..."

    bench new-site $SITE \
        --admin-password $ADMIN_PASSWORD \
        --db-type postgres

    bench --site $SITE install-app leave_management
fi

echo "Starting Frappe..."

bench serve --port $PORT
