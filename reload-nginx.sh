#!/bin/bash

sed -i 's/to_be_replace/green/g' proxy/nginx.conf
# Getting Nginx container ID
image_name=`docker ps | grep  sprint-name-generator-proxy-1 | awk '{print $1}'`
# Copying configs for green deployment
docker cp proxy/nginx.conf ${image_name}:etc/nginx/conf.d/

# Checking OS to make sure docker exec doesn't fail to reload nginx configs
case $( uname -s ) in
  Linux)
    docker exec -it ${image_name} service nginx reload;;
  *)
    winpty docker exec -it ${image_name} service nginx reload;;
esac

sed -i 's/green/to_be_replace/g' proxy/nginx.conf

