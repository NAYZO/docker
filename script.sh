#!/bin/bash

# Restart rsyslog
service rsyslog restart

# Restart rabbitmq server + Add new user
service rabbitmq-server restart


# Set cache and logs Permissions of the optedif-v2-local project
setfacl -dR -m u:"www-data":rwX -m u:$(whoami):rwX /var/www/optedif-v2-local/app/cache /var/www/optedif-v2-local/app/logs
setfacl -R -m u:"www-data":rwX -m u:$(whoami):rwX /var/www/optedif-v2-local/app/cache /var/www/optedif-v2-local/app/logs

# Add projects Permissions
cd /var/www/ && chown -R www-data:www-data *
