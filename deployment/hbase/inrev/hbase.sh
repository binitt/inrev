#!/bin/bash

source inrev/hbase.env

case $1 in
"start")
  ./bin/start-hbase.sh
;;

"stop")
  ./bin/stop-hbase.sh
;;

"check")
  echo "==============";
  echo "Checking Master:"
  jps | grep [H]Master
  echo "==============";
  for s in $(cat conf/regionservers); do
    echo "==============";
    echo "Checking RegionServer: $s";
    ssh -t $USER@$s "cd $HBASE_HOME && jps | grep [H]RegionServer"
    echo "==============";
  done
;;

"sync-slave")
  for s in $(cat conf/regionservers); do
    echo "==============";
    echo "Syncing slave: $s";
    rsync -av conf/ $USER@$s:$HBASE_HOME/conf/
    echo "==============";
  done
;;

"clear-logs")
  for s in $(cat etc/hadoop/slaves);
  do
    echo "==============";
    echo "Deleting logs slave: $s";
    ssh -t $USER@$s "rm -r $HBASE_HOME/logs/*"
    echo "==============";
  done
;;


*)
  echo "Usage 1: $0 <start|stop|check>";
  echo "Usage 2: $0 <sync-slave|clear-logs>";
  exit 1;
esac
