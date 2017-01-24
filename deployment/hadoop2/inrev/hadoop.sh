#!/bin/bash

source inrev/hadoop.env

case $1 in
"start")
  $0 "start-master"
  $0 "start-slave"
;;

"stop")
  $0 "stop-master"
  $0 "stop-slave"
;;

"check")
  $0 "check-master"
  $0 "check-slave"
;;

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

"check-slave-single")
  ps -ef | perl -lne "print \"\$1 \$2\" if m/^(?!root)\\w+\\s*(\\d+).*\\.(SecureDataNodeStarter|NodeManager)/"
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
  echo "Usage 1: $0 <start|stop|check>";
  echo "Usage 2: $0 <start-master|stop-master|check-master>";
  echo "Usage 3: $0 <start-slave|stop-slave|sync-slave|check-slave>";
  echo "Usage 4: $0 <start-slave-single|stop-slave-single|check-slave-single>";
  echo "Usage 5: $0 <clear-logs|format>";
  exit 1;
esac
