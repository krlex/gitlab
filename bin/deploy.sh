#!/bin/env bash

deploy_docker(){
  sudo docker compose --env-file ../.env -f ../docker-compose.yml
}

deploy_docker
