#!/usr/bin/env bash
docker run -d --name mongodb percona/percona-server-mongodb:latest
docker build . --name crits-web
docker run --rm --link mongodb:mongodb crits-web python manage.py create_default_collections
docker-compose up