#!/bin/bash


function usage
{
  echo "$0 <start|stop|check>";
}


STAMP=$(basename $(pwd))

if [ $# -ne 1 ]
then
  usage;
  exit 1;
fi

if [ $(uname) == "Linux" ]
then
  DELIM=":"
else
  DELIM=";"
fi


case $1 in 
  "start")
  rm -f nohup.out
  nohup java -cp "resources${DELIM}libs/*${DELIM}target/*${DELIM}target/dependency/*" com.inrev.bms.job.BMSolrJsonIndexer &
  ;;


  "stop")
  ps -ef | grep "[c]om.inrev.bms.job.BMSolrJsonIndexer.*$STAMP" | awk '{print $2}' | xargs kill -9
  ;;


  "check")
  ps -ef | grep "[c]om.inrev.bms.job.BMSolrJsonIndexer.*$STAMP"
  ;;


  *)
  echo "Unrecognized command: $1";
  usage;
  exit 1;
  ;;
esac

