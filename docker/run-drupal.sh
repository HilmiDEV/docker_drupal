#!/usr/bin/env bash

docker-compose stop
docker-compose kill
docker-compose rm -f
sleep 2
docker-compose build
sleep 2
docker-compose up
docker-compose logs -f drupal


