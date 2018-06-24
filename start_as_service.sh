#!/bin/sh

. ./common.sh

DOMAIN=node.lyon.infa.co
DNS_HOST=172.17.0.2
SERVICE_NAME=hadoop
DOCKER_IMAGE=lntinfa/hadoop-docker:$HADOOP_VERSION
DATA_DIR=/home/docker-data/data
REPLICAS=1

docker service create \
	--name ${SERVICE_NAME} \
	--replicas=${REPLICAS} \
	--hostname="{{.Service.Name}}-{{.Task.Slot}}.${DOMAIN}" \
	--dns=${DNS_HOST} \
	--dns-search=${DOMAIN} \
	--env UPDATE_DNS=true \
	--env MASTER_NODE=${SERVICE_NAME}-1.${DOMAIN} \
	--mount type=bind,src=${DATA_DIR}/${SERVICE_NAME},dst=/export \
	${DOCKER_IMAGE}

        #--publish 58088:8088 \
	#--publish 58042:8042 \
	#--publish 59888:19888 \
