#! /usr/bin/env sh

# Exit in case of error
set -e

docker compose \
-f ./docker-compose/docker-compose.dev.yml \
config > ./docker-compose/docker-stack.yml

docker compose -f ./docker-compose/docker-stack.yml build
docker compose -f ./docker-compose/docker-stack.yml down --remove-orphans
docker compose -f ./docker-compose/docker-stack.yml up -d