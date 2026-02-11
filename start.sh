#!/bin/bash
set -e

echo "Starting Frappe on Render..."

cd /home/frappe/frappe-bench

# Activate bench virtual environment (CRITICAL FIX)
source env/bin/activate

SITE=${SITE_NAME:-site1.local}

# Create site directory
mkdir -p sites/$SITE

# Create site_config.json
cat > sites/$SITE/site_config.json <<EOF
{
 "db_type": "postgres",
 "db_host": "$DB_HOST",
 "db_port": $DB_PORT,
 "db_name": "$DB_NAME",
 "db_user": "$DB_USER",
 "db_password": "$DB_PASSWORD",
 "redis_cache": "$REDIS_URL",
 "redis_queue": "$REDIS_URL",
 "redis_socketio": "$REDIS_URL"
}
EOF

echo "$SITE" > sites/currentsite.txt

echo "Python path:"
which python

echo "Gunicorn path:"
which gunicorn

echo "Starting gunicorn..."

exec gunicorn \
  --chdir /home/frappe/frappe-bench \
  --bind 0.0.0.0:${PORT} \
  --workers 2 \
  --threads 4 \
  --timeout 120 \
  frappe.app:application
