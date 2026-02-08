FROM frappe/bench:latest

USER frappe

WORKDIR /home/frappe

COPY development/apps.json /home/frappe/apps.json

RUN bench init frappe-bench --frappe-branch version-15

WORKDIR /home/frappe/frappe-bench

RUN bench get-app --apps_path /home/frappe/apps.json

EXPOSE 8000

CMD ["bench", "start"]
