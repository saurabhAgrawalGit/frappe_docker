#!/bin/bash

set -e

echo "Starting Frappe on Render..."

cd /home/frappe/frappe-bench

SITE=${SITE_NAME:-site1.local}

# Start Redis
echo "Starting Redis..."
redis-server --daemonize yes

sleep 3

# Create site folder
mkdir -p sites/$SITE

# Create site_config.json manually (NO bench new-site)
cat > sites/$SITE/site_config.json <<EOF
{
 "db_type": "postgres",
 "db_host": "$DB_HOST",
 "db_port": $DB_PORT,
 "db_name": "$DB_NAME",
 "db_user": "$DB_USER",
 "db_password": "$DB_PASSWORD",
 "redis_cache": "redis://127.0.0.1:6379",
 "redis_queue": "redis://127.0.0.1:6379",
 "redis_socketio": "redis://127.0.0.1:6379"
}
EOF

# Set current site
echo "$SITE" > sites/currentsite.txt

# DO NOT run bench new-site
# DO NOT run bench start

echo "Starting gunicorn..."

exec gunicorn \
 --chdir /home/frappe/frappe-bench \
 --bind 0.0.0.0:${PORT:-10000} \
 --workers 2 \
 --threads 4 \
 --timeout 120 \
 frappe.app:application
