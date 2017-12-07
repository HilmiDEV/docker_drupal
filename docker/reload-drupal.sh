#!/usr/bin/env bash

docker-compose stop
sleep 2
docker-compose up
docker-compose logs -f drupal





