#!/bin/bash

echo "Stop old container and run a new one"

docker container stop $(docker ps -q) 
docker container rm $(docker ps -q) 
docker run -d -p 80:8080 --name $1 $2
