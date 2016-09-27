#!/bin/bash

#this will update all containers and cause a brief moment of downtime

echo "precompiling assets.."
rails assets:precompile

echo "transferring files..."

rsync -a -e "ssh -i $EC2_IDENTITY_FILE" ../docker-rails-school-complete $EC2_HOST:~ --exclude=.git --exclude=docker-compose.override.yml

echo "complete!"

ssh -t -i $EC2_IDENTITY_FILE $EC2_HOST "cd $(basename $(PWD)) && config/deploy/docker_build_and_start.sh"

echo "cleaning up precompiled assets..."
rm -rf public/assets