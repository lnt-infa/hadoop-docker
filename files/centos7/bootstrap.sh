#!/bin/bash -x

: ${HADOOP_HOME:=/usr/local/hadoop}
: ${EXPORT_PREFIX:=/export}
: ${NODE_TYPE:=MASTER}
: ${MASTER_NODE:=`hostname`}

#if [ `echo $HADOOP_VERSION | cut -d "." -f 1` -ge 3 ]; then
#  export HADOOP_HOME=$HADOOP_PREFIX
#fi

. /etc/profile.d/hadoop-env.sh


source /etc/consulFunctions.sh

rm /tmp/*.pid

# altering the core-site configuration
sed s/HOSTNAME/$MASTER_NODE/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
sed s/MASTER_NODE/$MASTER_NODE/ /usr/local/hadoop/etc/hadoop/yarn-site.xml.template > /usr/local/hadoop/etc/hadoop/yarn-site.xml
# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_HOME/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

if [[ $1 == "-bash" ]]; then
  /bin/bash
elif [[ $1 == "-build-native" ]]; then
  /etc/build-native.sh
else

  #service sshd start
  nohup /usr/sbin/sshd -D &
  
  # creating the log dirs
  mkdir -p $HADOOP_LOG_DIR && chown hdfs: $HADOOP_LOG_DIR && chmod 775 $HADOOP_LOG_DIR
  [ ! -z "$YARN_LOG_DIR" ] &&  mkdir -p $YARN_LOG_DIR && chown yarn: $YARN_LOG_DIR
  [ ! -z "$HADOOP_MAPRED_LOG_DIR" ] &&  mkdir -p $HADOOP_MAPRED_LOG_DIR && chown mapred: $HADOOP_MAPRED_LOG_DIR
  
  # creating data dir
  for u in `echo hdfs yarn mapred`; do mkdir -p $EXPORT_PREFIX/data/$u && chown $u: $EXPORT_PREFIX/data/$u; done
  
  if [ "$NODE_TYPE" = "MASTER" -a "$MASTER_NODE" = `hostname` ]; then 
  
    # only -format namenode the first time
    su hdfs -c "$HADOOP_HOME/bin/hdfs namenode -format -nonInteractive"
    
    ln -s $HADOOP_CONF_DIR/slaves /etc/hadoop/workers
  
    su hdfs -c "$HADOOP_HOME/sbin/start-dfs.sh"
    su yarn -c "$HADOOP_HOME/sbin/start-yarn.sh"
  
    su hdfs -c "$HADOOP_HOME/bin/hdfs dfs -mkdir /tmp"
    su hdfs -c "$HADOOP_HOME/bin/hdfs dfs -chmod 777 /tmp"
    if [ `echo $HADOOP_VERSION | cut -d "." -f 1` -ge 3 ]; then
      su mapred -c "$HADOOP_HOME/bin/mapred --config $HADOOP_CONF_DIR  --daemon start historyserver"
    else
      su mapred -c "$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver"
    fi
  else
    if [ `echo $HADOOP_VERSION | cut -d "." -f 1` -ge 3 ]; then
      su hdfs -c "$HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR --daemon start datanode"
      su yarn -c "$HADOOP_HOME/bin/yarn --config $HADOOP_CONF_DIR --daemon start nodemanager"
    else
      su hdfs -c "$HADOOP_HOME/sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs start datanode"
      su yarn -c "$HADOOP_HOME/sbin/yarn-daemons.sh --config $HADOOP_CONF_DIR start nodemanager"
    fi
  fi

  if [[ $1 == "-d" ]]; then
    while true; do sleep 1000; done
  fi
fi


