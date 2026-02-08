#!/bin/bash

cd /home/frappe/frappe-bench

SITE="frappedocker-production-b75f.up.railway.app"

echo "Railway PORT is: $PORT"

# Configure frappe to use Railway port
bench set-config -g webserver_port $PORT
bench set-config -g socketio_port $PORT

# Create site if not exists
if [ ! -d "sites/$SITE" ]; then
    echo "Creating new site..."

    bench new-site $SITE \
        --admin-password $ADMIN_PASSWORD \
        --db-type postgres \
        --no-mariadb-socket

    bench --site $SITE install-app leave_management

    bench use $SITE
fi

echo "Starting Frappe on port $PORT"

# Start frappe on correct port
bench start
