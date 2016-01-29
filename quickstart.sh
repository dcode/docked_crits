#!/usr/bin/env bash
# build crits-web
docker build -t crits-web .
#echo "Starting percona-server-mongodb"
#docker run -d --rm --name mongodb percona/percona-server-mongodb:latest
echo "running crits with link to mongodb"
docker run --rm --link mongodb:mongodb crits-web python /data/crits/manage.py create_default_collections
docker run --rm --link mongodb:mongodb crits-web python /data/crits/manage.py users -a -A -e admin@foo.org -f admin -l admin -o foo -u admin
echo "container built! Run \n"
echo "docker-compose run -d ."