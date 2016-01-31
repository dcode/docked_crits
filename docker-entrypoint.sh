#!/usr/bin/env bash

ADMIN_ORG="ACME, Inc"
ADMIN_FIRSTNAME="Wiley"
ADMIN_LASTNAME="Coyote"

if [ ! -f  /data/crits/crits/config/database.py ]; then
			
	cp /data/crits/crits/config/database_example.py /data/crits/crits/config/database.py && \
		SC=$(cat /dev/urandom | LC_CTYPE=C tr -dc 'abcdefghijklmnopqrstuvwxyz0123456789!@#%^&*(-_=+)' | fold -w 50 | head -n 1) && \
		SE=$(echo ${SC} | sed -e 's/\\/\\\\/g' | sed -e 's/\//\\\//g' | sed -e 's/&/\\\&/g') && \
		sed -i -e "s/^\(SECRET_KEY = \).*$/\1\'${SE}\'/1" /data/crits/crits/config/database.py && \
		sed -i -e "s/^\(MONGO_HOST = \).*$/\1\os.environ['MONGODB_PORT_27017_TCP_ADDR']/1" /data/crits/crits/config/database.py  # need to change the mongo host to the docker image name
	#
	# Creates default info, if it already exists, it skips by default
	python /data/crits/manage.py create_default_collections

	# Add a CRITS admin user, not sure what happens if it exists
	python /data/crits/manage.py users --adduser  \
	--administrator \
	--email ${ADMIN_EMAIL} \
	--firstname ${ADMIN_FIRSTNAME} \
	--lastname ${ADMIN_LASTNAME} \
	--organization ${ADMIN_ORG} \
	--username ${ADMIN_USERNAME} 
fi

exec python /data/crits/manage.py runserver 0.0.0.0:8080 
