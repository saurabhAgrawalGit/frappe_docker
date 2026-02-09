#!/bin/bash

cd /home/frappe/frappe-bench

SITE=$SITE_NAME

echo "Starting site creation..."

bench set-config -g webserver_port $PORT

if [ ! -d "sites/$SITE" ]; then

    bench new-site $SITE \
        --admin-password $ADMIN_PASSWORD \
        --db-type postgres

    bench --site $SITE install-app leave_management

fi

bench serve --port $PORT
