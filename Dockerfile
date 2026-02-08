FROM frappe/bench:latest

USER root

# Install Redis
RUN apt-get update && apt-get install -y redis-server

USER frappe

WORKDIR /home/frappe

# Copy apps.json
COPY development/apps.json /home/frappe/apps.json

# Initialize bench
RUN bench init frappe-bench --frappe-branch version-15

WORKDIR /home/frappe/frappe-bench

# Install your apps
RUN bench get-app --apps_path /home/frappe/apps.json

EXPOSE 8000

CMD ["bench", "start"]
