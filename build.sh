#!/bin/bash
age --decrypt --output id_rsa_shared id_rsa_shared.age
age --decrypt --output action.env action.env.age
docker build . -t actions-image:latest --build-arg DOCKER_GROUP_ID=`getent group docker | cut -d: -f3`
