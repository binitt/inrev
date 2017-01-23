#!/bin/bash

source inrev/env.sh

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
  if [ "$KERBEROS_ENABLED" -eq "1" ]; then
    for s in $(cat etc/hadoop/slaves); do
      ssh -t $USER@$s "cd $HADOOP_HOME && sudo sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start datanode"
    done
  else
    sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs start datanode
  fi
  sbin/yarn-daemons.sh --config $HADOOP_CONF_DIR start nodemanager
;;

"stop-slave")
  if [ "$KERBEROS_ENABLED" -eq "1" ]; then
    for s in $(cat etc/hadoop/slaves); do
      ssh -t $USER@$s "cd $HADOOP_HOME && sudo sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs stop datanode"
    done
  else
    sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs stop datanode
  fi
  sbin/yarn-daemons.sh --config $HADOOP_CONF_DIR stop nodemanager
;;

"start-slave-single")
  if [ "$KERBEROS_ENABLED" -eq "1" ]; then
    sudo sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start datanode
  else
    sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start datanode
  fi
  sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start nodemanager
;;

"stop-slave-single")
  if [ "$KERBEROS_ENABLED" -eq "1" ]; then
    sudo sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs stop datanode
  else
    sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs stop datanode
  fi
  sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop nodemanager
;;

"check-slave")
  for s in $(cat etc/hadoop/slaves);
  do
	echo "==============";
	echo "Checking slave: $s";
	ssh -t linux@linux13 'ps -ef | perl -lne "print \"\$1 \$2\" if m/^(?!root)\\w+\\s*(\\d+).*\\.(SecureDataNodeStarter|NodeManager)/"'
	echo "==============";
  done
;;

"sync-slave")
  for s in $(cat etc/hadoop/slaves);
  do
	echo "==============";
	echo "Syncing slave: $s";
	rsync -tvr etc/hadoop/ $USER@$s:$HADOOP_CONF_DIR/
	echo "==============";
  done
;;

"clear-logs")
  for s in $(cat etc/hadoop/slaves);
  do
    echo "==============";
    echo "Deleting logs slave: $s";
    ssh -t $USER@$s "sudo rm -r $HADOOP_HOME/logs/*"
    echo "==============";
  done
;;


"format")
  echo "Deleting old data if present"
  for s in $(cat etc/hadoop/slaves);
  do    
        echo "  In slave: $s";
        ssh $USER@$s 'rm -rf hadoop/data/*'
  done
  
  rm -rf data
  bin/hdfs namenode -format cluster_name
;;

*)
  echo "Usage: $0 <start-master|stop-master|start-slave|stop-slave|sync-slave|check-slave|clear-logs|format>";
  exit 1;
esac
