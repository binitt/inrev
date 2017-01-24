#!/bin/bash

case $1 in
  "start")
  nohup ./inrev/start_crawl.sh &
  ;;

  "stop")
    ps -ef | egrep "[s]tart_crawl.sh|[s]ingle-crawler.sh" | awk '{print $2}' | xargs kill -9
  ;;

  "check")
    ps -ef | egrep "[s]tart_crawl.sh|[s]ingle-crawler.sh"
  ;;

  *)
  ;;
esac

