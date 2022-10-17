#!/bin/bash

if [[ $1 == "cleanup" ]]
then

  docker compose -f compose-blue.yaml stop && docker-compose -f compose-blue.yaml rm -f

  docker compose -f compose-green.yaml stop && docker-compose -f compose-green.yaml rm -f

  docker network rm sprint-name-generator_default

elif [[ $1 == "blue" ]]
then

  docker container prune -f
  sed -i 's/to_be_replace/blue/g' proxy/nginx.conf

  # Blue Deployment
  docker compose -f compose-blue.yaml up -d

  psStatus=`docker compose ls | awk 'FNR>1 {print $2}' | grep "running"`

  if [[ $psStatus == "running"* ]]
  then
    sleep 5
    echo "Blue is deployed!"
  else
    echo "Blue deployment was unsuccessful!"
  fi

  sed -i 's/blue/to_be_replace/g' proxy/nginx.conf

elif [[ $1 == "green" ]]
then

  numOfDockerPs=`docker compose ls | awk 'FNR>1 {print $2}' | tr -dc '0-9'`

  if [[ $numOfDockerPs == 2 ]]
  then
    # Force any change in image
    docker compose -f compose-green.yaml build --no-cache
    # Green Deployment
    docker compose -f compose-green.yaml  up -d
    sleep 5
    echo "Green is deployed successfully!"

  elif [[ $numOfDockerPs -ge 2 ]]
  then
    echo "Green is deployed!"

  else
    echo "Deployment blue is not even running"
  fi

else
  echo "Choose one option from blue or green"
fi



