# Creates pseudo distributed/distributed hadoop 2.7.5
#   * run each component as separate non-root and separate user
#   * pre-compiled version of hadoop native with openssl and snappy support 

FROM lntinfa/infa-base
MAINTAINER LNT

USER root

ARG HADOOP_VERSION
ENV HADOOP_VERSION=${HADOOP_VERSION:-2.7.6}

# hadoop
RUN yum install -y snappy-devel openssl-devel zlib-devel

RUN curl -s http://www.eu.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./hadoop-${HADOOP_VERSION} hadoop

#COPY centos7/hadoop-native-64-${HADOOP_VERSION}.tgz /tmp/hadoop-native-64-${HADOOP_VERSION}.tgz
RUN curl -LO https://github.com/lnt-infa/infa-hadoop/raw/master/files/centos7/hadoop-native-64-${HADOOP_VERSION}.tgz && mv hadoop-native-64-${HADOOP_VERSION}.tgz /tmp/
RUN tar -xzf /tmp/hadoop-native-64-${HADOOP_VERSION}.tgz -C /tmp
RUN rm -rf /usr/local/hadoop/lib/native && mv /tmp/native /usr/local/hadoop/lib

ARG EXPORT_PREFIX=/export

ARG HADOOP_PREFIX=/usr/local/hadoop

# pseudo distributed
ADD files/hadoop-${HADOOP_VERSION}/core-site.xml.template $HADOOP_PREFIX/etc/hadoop/core-site.xml.template
#RUN sed s/HOSTNAME/localhost/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
ADD files/hadoop-${HADOOP_VERSION}/hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml

ADD files/hadoop-${HADOOP_VERSION}/mapred-site.xml $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
ADD files/hadoop-${HADOOP_VERSION}/yarn-site.xml.template $HADOOP_PREFIX/etc/hadoop/yarn-site.xml.template

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


ADD files/centos7/bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

ADD files/centos7/build-native.sh /etc/build-native.sh
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

