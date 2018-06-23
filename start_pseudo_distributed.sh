#!/bin/sh

. ./common.sh

DOMAIN=node.lyon.infa.co
DNS_HOST=172.17.0.2
MASTER="hdp1"
DOCKER_IMAGE=lntinfa/hadoop-docker:$OS-$HADOOP_VERSION
DATA_DIR=/home/docker-data/data


# start the master
docker run -d --name ${MASTER} -h ${MASTER}.${DOMAIN} -p 8088:8088 -p 8042:8042 -p 19888:19888 --dns=${DNS_HOST} --dns-search=${DOMAIN} -e NODE_TYPE=MASTER -e MASTER_NODE=${MASTER}.${DOMAIN} -v ${DATA_DIR}/${MASTER}:/export ${DOCKER_IMAGE}
