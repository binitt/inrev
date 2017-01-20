#!/bin/bash


export HADOOP_CONF_DIR=/home/linux/hadoop/etc/hadoop


case $1 in
"start-master")
  sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start namenode
  sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start resourcemanager
  sbin/mr-jobhistory-daemon.sh start historyserver --config $HADOOP_CONF_DIR
;;


"stop-master")
  sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs stop namenode
  sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop resourcemanager
  sbin/mr-jobhistory-daemon.sh stop historyserver --config $HADOOP_CONF_DIR
;;


"check-master")
  echo "==============";
  echo "Checking Master: $(hostname)";
  jps | egrep "[N]ameNode|JobHistoryServer|ResourceManager"
  echo "==============";
;;


"start-slave")
  sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs start datanode
  sbin/yarn-daemons.sh --config $HADOOP_CONF_DIR start nodemanager
;;


"stop-slave")
  sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs stop datanode
  sbin/yarn-daemons.sh --config $HADOOP_CONF_DIR stop nodemanager
;;


"check-slave")
  for s in $(cat etc/hadoop/slaves);
  do
    echo "==============";
    echo "Checking slave: $s";
    ssh linux@$s 'jps | egrep "NodeManager|[D]ataNode"';
    echo "==============";
  done
;;


"sync-slave")
  for s in $(cat etc/hadoop/slaves);
  do
    echo "==============";
    echo "Syncing slave: $s";
    rsync -tvr etc/ linux@$s:hadoop/etc/
    echo "==============";
  done
;;




"format")
  bin/hdfs namenode -format cluster_name
;;


*)
  echo "Usage: $0 <start-master|stop-master|start-slave|stop-slave|sync-slave>";
  exit 1;
esac
