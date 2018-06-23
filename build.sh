#!/bin/sh

. ./common.sh


docker build -f $OS/Dockerfile --build-arg HADOOP_VERSION=${HADOOP_VERSION} -t lntinfa/hadoop-docker:$OS-$HADOOP_VERSION .
