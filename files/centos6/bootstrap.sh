#!/bin/bash -x

: ${HADOOP_PREFIX:=/usr/local/hadoop}
: ${EXPORT_PREFIX:=/export}
: ${NODE_TYPE:=MASTER}
: ${MASTER_NODE:=`hostname`}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh


source /etc/consulFunctions.sh

rm /tmp/*.pid

# altering the core-site configuration
sed s/HOSTNAME/$MASTER_NODE/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
sed s/MASTER_NODE/$MASTER_NODE/ /usr/local/hadoop/etc/hadoop/yarn-site.xml.template > /usr/local/hadoop/etc/hadoop/yarn-site.xml
# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -


service sshd start

# creating the log dirs
mkdir -p $HADOOP_LOG_DIR && chown hdfs: $HADOOP_LOG_DIR
mkdir -p $YARN_LOG_DIR && chown yarn: $YARN_LOG_DIR
mkdir -p $HADOOP_MAPRED_LOG_DIR && chown mapred: $HADOOP_MAPRED_LOG_DIR

# creating data dir
for u in `echo hdfs yarn mapred`; do mkdir -p $EXPORT_PREFIX/data/$u && chown $u: $EXPORT_PREFIX/data/$u; done

if [ "$NODE_TYPE" = "MASTER" -a "$MASTER_NODE" = `hostname` ]; then 

  # only -format namenode the first time
  su hdfs -c "$HADOOP_PREFIX/bin/hdfs namenode -format -nonInteractive"

  su hdfs -c "$HADOOP_PREFIX/sbin/start-dfs.sh"
  su yarn -c "$HADOOP_PREFIX/sbin/start-yarn.sh"

  su hdfs -c "$HADOOP_PREFIX/bin/hdfs dfs -mkdir /tmp"
  su hdfs -c "$HADOOP_PREFIX/bin/hdfs dfs -chmod 777 /tmp"
  su mapred -c "$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh start historyserver"
else
  su hdfs -c "$HADOOP_PREFIX/sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs start datanode"
  su yarn -c "$HADOOP_YARN_HOME/sbin/yarn-daemons.sh --config $HADOOP_CONF_DIR start nodemanager"
fi


if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
