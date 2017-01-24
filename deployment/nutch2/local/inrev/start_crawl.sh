#!/bin/bash

echo "$$" > my.pid
while [ 1 ]
do
  DATE=$(date)
  echo
  echo "Starting next crawl cycle at: $DATE"

  SIZE=$(wc -l inrev/superseed.txt | awk '{ print $1}')
  echo "Using inrev/superseed.txt as seed, total: $SIZE"
  rm -rf urls/ && mkdir -p urls/ && cp inrev/superseed.txt urls/ &&
  ./inrev/single-crawler.sh urls/ cslocal "http://linux08:8983/solr/sites" 2

  sleep 120
done
