#!/bin/sh

. ./common.sh

DOMAIN=node.lyon.infa.co
DNS_HOST=172.17.0.2
WORKERS="hdp2 hdp3 hdp4"
MASTER="hdp1"
SLAVES_FILE=${PWD}/slaves.tmp
DOCKER_IMAGE=lntinfa/hadoop-docker:$OS-$HADOOP_VERSION
DATA_DIR=/home/docker-data/data

rm ${SLAVES_FILE}

# start the workers
for i in `echo $WORKERS`; do
  docker run -d --name ${i} -h ${i}.${DOMAIN} --dns=${DNS_HOST} --dns-search=${DOMAIN} -e NODE_TYPE=WORKER -e MASTER_NODE=${MASTER}.${DOMAIN} --env UPDATE_DNS=true -v ${DATA_DIR}/${i}:/export ${DOCKER_IMAGE}
  echo ${i}.${DOMAIN} >> ${SLAVES_FILE}
done

# start the master
docker run -d --name ${MASTER} -h ${MASTER}.${DOMAIN} -p 8088:8088 -p 8042:8042 -p 19888:19888 --dns=${DNS_HOST} --dns-search=${DOMAIN} -e NODE_TYPE=MASTER -e MASTER_NODE=${MASTER}.${DOMAIN} --env UPDATE_DNS=true -v ${SLAVES_FILE}:/etc/hadoop/conf/slaves -v ${DATA_DIR}/${MASTER}:/export ${DOCKER_IMAGE}
