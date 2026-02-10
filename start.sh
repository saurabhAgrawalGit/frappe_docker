#!/bin/bash

cd /home/frappe/frappe-bench

SITE=${SITE_NAME:-frappedocker-production-b75f.up.railway.app}
ADMIN_PASS=${ADMIN_PASSWORD:-admin}
PORT=8000

echo "========================================"
echo "Starting Frappe Railway Deployment"
echo "Site: $SITE"
echo "Port: $PORT"
echo "========================================"

# Show bench and frappe version
echo "Checking Bench Version..."
bench --version

echo "Checking Installed Apps Version..."
bench version

# Set configs
echo "Setting global configs..."
bench set-config -g webserver_port $PORT
bench set-config -g db_type postgres

# Check if site exists
if [ ! -d "sites/$SITE" ]; then

    echo "----------------------------------------"
    echo "Site does not exist. Creating new site..."
    echo "----------------------------------------"

    bench new-site $SITE \
        --admin-password $ADMIN_PASS \
        --db-type postgres \
        --no-mariadb-socket

    echo "Site created successfully."

    echo "Installing leave_management app..."
    bench --site $SITE install-app leave_management || true

    echo "App installation completed."

else

    echo "----------------------------------------"
    echo "Site already exists. Skipping creation."
    echo "----------------------------------------"

fi

# Show site list
echo "Available sites:"
ls -l sites/

# Set default site
echo "Setting default site..."
bench use $SITE

# Final version check
echo "========================================"
echo "Final Bench Version:"
bench version
echo "========================================"

# Start server
echo "Starting Frappe server on port $PORT..."
bench serve --port $PORT
