#!/bin/bash

# split all app container names that are already running into an array
old_containers=($(docker-compose ps app | awk '{ print $1 }' | tail -n +3))

# fetch container name for nginx service
nginx_container=$(docker-compose ps $NGINX_SERVICE | awk '{ print $1 }' | tail -n +3)

# get number of running webapp containers to update
number_of_containers_to_start=${#old_containers[*]}

# get bridge network name from first container in array
export PROJECT_NETWORK=$(docker inspect -f "{{ .NetworkSettings.Networks }}" ${old_containers[0]} | grep -o -P '(?<=\[).*(?=:)')

# build app with new files
docker-compose build app

# create the new containers with latest code changes
docker-compose scale app=$(echo $(($number_of_containers_to_start*2)))

# creat array with new containers only
all_containers=($(docker-compose ps app | awk '{ print $1 }' | tail -n +3))

new_containers=($(echo ${old_containers[*]} ${all_containers[*]} | tr ' ' '\n' | sort | uniq -u))

# loop through containers and get IP addresses separated by / so they can be exported below
IP_ADDRESSES=""
for element in ${new_containers[*]}; do
  IP_ADDRESSES+="$(docker inspect -f {{.NetworkSettings.Networks.$PROJECT_NETWORK.IPAddress}} $element)/"
done

# run script to update the nginx_upstream.conf file
docker exec -i $nginx_container bash -c "export CONTAINERS=$IP_ADDRESSES && /opt/update_upstream_directive.sh"

echo "please wait 30 seconds for containers to be ready..."
sleep 30

# send nginx hangup signal to update the nginx_upstream.conf file
echo "gracefully restarting nginx..."
docker kill -s HUP $nginx_container

echo "stopping and cleaning up old containers..."
# stops the old containers
for container in $old_containers; do
  docker kill $container
done

# deletes the old containers
docker rm $(docker ps -aqf status=exited)

# rename new webapp containers to start at 1 and go up sequentially
newly_started_containers=($(docker-compose ps app | awk '{ print $1 }' | tail -n +3))
counter=0
while [ $counter -lt ${#newly_started_containers[*]} ]; do
  for container in $newly_started_containers; do
    new_name=$(echo "${container%?}$(($counter+1))")
    docker rename $container $new_name
  done
  let counter=counter+1
done

