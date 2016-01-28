#!/usr/bin/env bash
# build crits-web
docker build -t crits-web .
# start mongo
docker run -d --name mongodb percona/percona-server-mongodb:latest
# run crits-web and execute this script
docker run --rm --link mongodb:mongodb crits-web python /data/crits/manage.py create_default_collections
docker run --rm --link mongodb:mongodb crits-web python /data/crits/manage.py users -a -A -e admin@foo.org -f admin -l admin -o foo -u admin
docker-compose up 