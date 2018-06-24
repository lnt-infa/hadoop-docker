#!/bin/sh

. ./common.sh


docker build -f Dockerfile --build-arg HADOOP_VERSION=${HADOOP_VERSION} -t lntinfa/hadoop-docker:$HADOOP_VERSION .
