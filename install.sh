#!/bin/bash

# Build Docker
docker build -t dev_img .

# Run Docker
docker run -d \
    --name dev_cont \
    -p 80:80 -p 15672:15672 \
    -v /home/nzo/public_html:/var/www \
    --add-host="local.optedif-formation.fr:127.0.0.1" dev_img
#   --user www-data \
    
