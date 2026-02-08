#!/bin/bash

cd /home/frappe/frappe-bench

SITE=$SITE_NAME

echo "Using Railway PORT: $PORT"

# Configure ports correctly
bench set-config -g webserver_port $PORT
bench set-config -g socketio_port $((PORT+1))

# Create site if not exists
if [ ! -d "sites/$SITE" ]; then
    echo "Creating new site: $SITE"

    bench new-site $SITE \
        --admin-password $ADMIN_PASSWORD \
        --db-type postgres \
        --no-mariadb-socket

    bench --site $SITE install-app leave_management
    bench use $SITE
fi

# CRITICAL FIX: bind to 0.0.0.0
echo "Starting Frappe on 0.0.0.0:$PORT"

bench serve --port $PORT --host 0.0.0.0
