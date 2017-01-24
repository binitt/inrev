#!/bin/bash

case $1 in
  "start")
  nohup ./inrev/start_crawl.sh &
  ;;

  "stop")
    ps -ef | egrep "[s]tart_crawl.sh|[s]ingle-crawler.sh" | awk '{print $2}' | xargs kill -9
    J=$(./bin/mapred job -list 2>&1 | perl -lne 'print $1 if m/(job_\S+)\s*RUNNING/')
    if [ -n "$J" ]; then
      ./bin/mapred job -kill $J
    fi
  ;;

  "check")
    ps -ef | egrep "[s]tart_crawl.sh|[s]ingle-crawler.sh"
    J=$(./bin/mapred job -list 2>&1 | perl -lne 'print $1 if m/(job_\S+)\s*RUNNING/')
    echo "Currently running job: $J"
  ;;

  *)
    echo "Usage: $0 <start|stop|check>"
  ;;
esac

