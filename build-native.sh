#!/bin/sh

. ./common.sh

docker build -f $OS/Dockerfile.build --build-arg HADOOP_VERSION=${HADOOP_VERSION} -t lntinfa/hadoop-docker:$OS-tmp .

#docker run -it -v ${PWD}/$OS:/mnt --name=$OS-build-hadoop lntinfa/hadoop-docker:$OS-tmp /etc/bootstrap.sh -build-native
docker run -it -v ${PWD}/$OS:/mnt --name=$OS-build-hadoop lntinfa/hadoop-docker:$OS-tmp /etc/bootstrap.sh -bash

docker rm $OS-build-hadoop

docker rmi lntinfa/hadoop-docker:$OS-tmp


#docker build -f centos7/Dockerfile -t lntinfa/hadoop-docker:centos7-2.7.6 .
