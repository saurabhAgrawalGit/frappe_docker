#!/bin/bash

cd /home/frappe/frappe-bench

if [ ! -d "sites/frappedocker-production-b75f.up.railway.app" ]; then
    bench new-site frappedocker-production-b75f.up.railway.app \
        --admin-password $ADMIN_PASSWORD \
        --db-type postgres \
        --install-app leave_management \
        --no-mariadb-socket

    bench use frappedocker-production-b75f.up.railway.app
fi

bench start
