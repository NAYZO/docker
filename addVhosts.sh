#!/bin/bash

DOCKER_IP=$(docker inspect docker_nginx_1 | grep '"IPAddress"' | tail -1 | grep -Po '"IPAddress": "\K[^"]*')

while IFS='' read -r line || [[ -n "$line" ]]; do

	if [[ ! -z "$line" ]]; then
        sed -i "/$line/d" /etc/hosts
    	sudo echo "$DOCKER_IP $line" >> /etc/hosts
	fi

done < "$1"
