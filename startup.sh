#!/bin/bash

docker build -t centos-sv .
docker compose up -d
