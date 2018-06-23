#!/bin/sh

HADOOP_VERSION=${HADOOP_VERSION:-2.7.6}
MVN_VERSION=3.5.3
PBUF_VERSION=2.5.0-8


mount_dir=/mnt

if [ `echo $HADOOP_VERSION | cut -d "." -f 1` -ge 3 ]; then
  curl -kl -L http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -o epel-release-latest-7.noarch.rpm
  rpm -ivh epel-release-latest-7.noarch.rpm
  yum -y install gcc autoconf automake libconf zlib-devel openssl-devel cmake3 gcc-c++ snappy-devel make
  ln -s /usr/bin/cmake3 /usr/bin/cmake
else
  yum -y install gcc autoconf automake libconf zlib-devel openssl-devel cmake gcc-c++ snappy-devel make
fi


curl -k1 -L http://www.eu.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}-src.tar.gz -o hadoop-${HADOOP_VERSION}-src.tar.gz
tar -xvzf ../hadoop-${HADOOP_VERSION}-src.tar.gz
cd hadoop-${HADOOP_VERSION}-src

cd /usr/local
curl -L http://www-eu.apache.org/dist/maven/maven-3/${MVN_VERSION}/binaries/apache-maven-${MVN_VERSION}-bin.tar.gz -o apache-maven-${MVN_VERSION}-bin.tar.gz
tar -xvzf apache-maven-${MVN_VERSION}-bin.tar.gz
ln -s apache-maven-${MVN_VERSION}  maven

echo export M2_HOME=/usr/local/maven >> /etc/profile.d/maven.sh
echo export PATH=\${M2_HOME}/bin:\${PATH} >> /etc/profile.d/maven.sh

source /etc/profile.d/maven.sh

curl -k1 -L http://mirror.centos.org/centos/7/os/x86_64/Packages/protobuf-${PBUF_VERSION}.el7.x86_64.rpm -o protobuf-${PBUF_VERSION}.el7.x86_64.rpm
curl -k1 -L http://mirror.centos.org/centos/7/os/x86_64/Packages/protobuf-compiler-${PBUF_VERSION}.el7.x86_64.rpm -o protobuf-compiler-${PBUF_VERSION}.el7.x86_64.rpm
curl -k1 -L http://mirror.centos.org/centos/7/os/x86_64/Packages/protobuf-devel-${PBUF_VERSION}.el7.x86_64.rpm -o protobuf-devel-${PBUF_VERSION}.el7.x86_64.rpm

#curl -k1 -L ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/kalyaka/CentOS_CentOS-6/x86_64/protobuf-2.5.0-16.1.x86_64.rpm -o protobuf-2.5.0-16.1.x86_64.rpm
#curl -k1 -L ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/kalyaka/CentOS_CentOS-6/x86_64/protobuf-devel-2.5.0-16.1.x86_64.rpm -o protobuf-devel-2.5.0-16.1.x86_64.rpm
#curl -L ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/kalyaka/CentOS_CentOS-6/x86_64/protobuf-compiler-2.5.0-16.1.x86_64.rpm -o protobuf-compiler-2.5.0-16.1.x86_64.rpm
yum -y localinstall protobuf*.rpm


cd - 

mvn package -Pdist,native -DskipTests -Dtar

cp -r hadoop-dist/target/hadoop-${HADOOP_VERSION}/lib/native $HADOOP_PREFIX/lib/

cd $HADOOP_PREFIX/lib/

tar_file=hadoop-native-64-${HADOOP_VERSION}.tgz
tar -cvzf ${tar_file} native/*

mv ${tar_file} ${mount_dir}/
