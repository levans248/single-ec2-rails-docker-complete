#!/bin/bash

echo "updating nginx upsteam directive..."

IFS="/" read -r -a addresses <<< $CONTAINERS

echo "upstream rails_app {" > /etc/nginx/nginx_upstream.conf

for container in $addresses; do
  echo "  server $container:3000;" >> /etc/nginx/nginx_upstream.conf
done

echo "}" >> /etc/nginx/nginx_upstream.conf