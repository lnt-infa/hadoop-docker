# Creates pseudo distributed/distributed hadoop 2.7.5
#   * run each component as separate non-root and separate user
#   * pre-compiled version of hadoop native with openssl and snappy support 
# docker build -t sequenceiq/hadoop .

FROM centos:7.4.1708
MAINTAINER LNT

USER root

ARG HADOOP_VERSION
ENV HADOOP_VERSION=${HADOOP_VERSION:-2.7.6}

# install dev tools
RUN yum clean all; \
    rpm --rebuilddb; \
    yum install -y curl which tar sudo openssh-server openssh-clients rsync
# update libselinux. see https://github.com/sequenceiq/hadoop-docker/issues/14
RUN yum update -y libselinux

# passwordless ssh
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys


# java
RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-8u171-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie'
RUN rpm -i jdk-8u171-linux-x64.rpm
RUN rm jdk-8u171-linux-x64.rpm

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin
RUN rm /usr/bin/java && ln -s $JAVA_HOME/bin/java /usr/bin/java

# download native support
#RUN mkdir -p /tmp/native
#RUN curl -k1 -L https://github.com/sequenceiq/docker-hadoop-build/releases/download/v2.7.1/hadoop-native-64-2.7.1.tgz | tar -xz -C /tmp/native

# hadoop
RUN yum install -y snappy-devel openssl-devel zlib-devel

RUN curl -s http://www.eu.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./hadoop-${HADOOP_VERSION} hadoop

COPY centos7/hadoop-native-64-${HADOOP_VERSION}.tgz /tmp/hadoop-native-64-${HADOOP_VERSION}.tgz
RUN tar -xzf /tmp/hadoop-native-64-${HADOOP_VERSION}.tgz -C /tmp
RUN rm -rf /usr/local/hadoop/lib/native && mv /tmp/native /usr/local/hadoop/lib

ARG EXPORT_PREFIX=/export

ARG HADOOP_PREFIX=/usr/local/hadoop
#ENV HADOOP_COMMON_HOME /usr/local/hadoop
#ENV HADOOP_HDFS_HOME /usr/local/hadoop
#ENV HADOOP_MAPRED_HOME /usr/local/hadoop
#ENV HADOOP_YARN_HOME /usr/local/hadoop
#ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
#ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
#ENV HADOOP_LOG_DIR $EXPORT_PREFIX/log/hdfs
#ENV YARN_LOG_DIR $EXPORT_PREFIX/log/yarn
#ENV HADOOP_MAPRED_LOG_DIR $EXPORT_PREFIX/log/mapred

#RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/java/default\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
#RUN sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
#RUN . $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

#RUN mkdir $HADOOP_PREFIX/input
#RUN cp $HADOOP_PREFIX/etc/hadoop/*.xml $HADOOP_PREFIX/input

# pseudo distributed
ADD files/hadoop-${HADOOP_VERSION}/core-site.xml.template $HADOOP_PREFIX/etc/hadoop/core-site.xml.template
#RUN sed s/HOSTNAME/localhost/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
ADD files/hadoop-${HADOOP_VERSION}/hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml

ADD files/hadoop-${HADOOP_VERSION}/mapred-site.xml $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
ADD files/hadoop-${HADOOP_VERSION}/yarn-site.xml.template $HADOOP_PREFIX/etc/hadoop/yarn-site.xml.template

ADD files/ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

# run each component with different user.
RUN groupadd -r hadoop 
RUN useradd -r -g hadoop hdfs && mkdir -p /home/hdfs && chown hdfs: /home/hdfs && cp -r /root/.ssh /home/hdfs/.ssh && chown -R hdfs: /home/hdfs/.ssh
RUN useradd -r -g hadoop yarn && mkdir -p /home/yarn && chown yarn: /home/yarn && cp -r /root/.ssh /home/yarn/.ssh && chown -R yarn: /home/yarn/.ssh
RUN useradd -r -g hadoop mapred && mkdir -p /home/mapred && chown mapred: /home/mapred && cp -r /root/.ssh /home/mapred/.ssh && chown -R mapred: /home/mapred/.ssh

RUN for u in `echo hdfs yarn mapred`; do cp /etc/skel/.bashrc /home/$u/.bashrc && chown $u: /home/$u/.bashrc; done

# requirement to start solr on slider
RUN mkdir -p /etc/hadoop
RUN ln -s /usr/local/hadoop/etc/hadoop /etc/hadoop/conf

RUN for i in `ls -1 $HADOOP_PREFIX/bin/*  | grep -v cmd`; do ln -s $i /usr/bin/; done
RUN for i in `ls -1 $HADOOP_PREFIX/sbin/*  | grep -v cmd`; do ln -s $i /usr/sbin/; done
#RUN for i in `ls -1 $HADOOP_PREFIX/libexec/*  | grep -v cmd`; do ln -s $i /usr/libexec/; done

RUN echo @hadoop	soft nproc unlimited >> /etc/security/limits.conf
RUN echo @hadoop	hard nproc unlimited >> /etc/security/limits.conf

ADD files/hadoop-${HADOOP_VERSION}/hadoop-env.sh /etc/profile.d/hadoop-env.sh
RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/java/default:' /etc/profile.d/hadoop-env.sh
RUN sed -i '/^export HADOOP_PREFIX/ s:.*:export HADOOP_PREFIX=/usr/local/hadoop:' /etc/profile.d/hadoop-env.sh
RUN sed -i '/^export HADOOP_HOME/ s:.*:export HADOOP_HOME=/usr/local/hadoop\n:' /etc/profile.d/hadoop-env.sh
RUN sed -i '/^export EXPORT_PREFIX/ s:.*:export EXPORT_PREFIX=/export\n:' /etc/profile.d/hadoop-env.sh


RUN chmod 755 /etc/profile.d/hadoop-env.sh

RUN curl  -LO https://raw.githubusercontent.com/lnt-infa/docker-common-scripts/master/consulFunctions.sh && cp consulFunctions.sh /etc/consulFunctions.sh

ADD centos7/bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

ADD centos7/build-native.sh /etc/build-native.sh
RUN chmod 700 /etc/build-native.sh

ENV BOOTSTRAP /etc/bootstrap.sh

# workingaround docker.io build error
#RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh
RUN chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh
#RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh


CMD ["/etc/bootstrap.sh", "-d"]

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 10020 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
