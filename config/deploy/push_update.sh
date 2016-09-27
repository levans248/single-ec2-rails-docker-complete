#!/bin/bash
echo "precompiling assets.."
rails assets:precompile

echo "transferring files..."

rsync -a -e "ssh -i $EC2_IDENTITY_FILE" ../$(echo $(basename $(PWD))) $EC2_HOST:~ --exclude=.git --exclude=docker-compose.override.yml

echo "complete!"

ssh -t -i $EC2_IDENTITY_FILE $EC2_HOST "export NGINX_SERVICE=$1 && export APP_SERVICE=$2 && cd $(basename $(PWD)) && config/deploy/update_containers.sh"

echo "cleaning up precompiled assets..."
rm -rf public/assets