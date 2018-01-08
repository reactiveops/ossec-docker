#!/bin/bash

#
# OSSEC container bootstrap. See the README for information of the environment
# variables expected by this script.
#
FIRST_TIME_INSTALLATION=false
DATA_PATH=/var/ossec/data

source /data_dirs.env
for ossecdir in "${DATA_DIRS[@]}"; do
	if [ ! -e "${DATA_PATH}/${ossecdir}" ]; then
    echo "Installing ${ossecdir}"
		mkdir -p ${DATA_PATH}/${ossecdir}
    cp -a /var/ossec/${ossecdir}-template/* ${DATA_PATH}/${ossecdir}/ 2>/dev/null
	fi
done
chown -R ossec:ossec /var/ossec/data/


if [ ! -f ${DATA_PATH}/etc/sslmanager.key ]; then
	openssl genrsa -out ${DATA_PATH}/etc/sslmanager.key 4096
	openssl req -new -x509 -key ${DATA_PATH}/etc/sslmanager.key -out ${DATA_PATH}/etc/sslmanager.cert -days 3650 -subj /CN=${HOSTNAME}/
fi

chmod -R g+rw ${DATA_PATH}/logs/ ${DATA_PATH}/stats/ ${DATA_PATH}/queue/

# Add a dummy agent so remoted can start
# if [ ! -s /var/ossec/etc/client.keys ] ; then
# 	/var/ossec/bin/manage_agents -f /var/ossec/default_agent
# fi

# Start service
exec $@
