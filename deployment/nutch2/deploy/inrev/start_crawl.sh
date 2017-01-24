#!/bin/bash

source inrev/nutch.env
MAXDEPTH=3

echo "$$" > my.pid
while [ 1 ]
do
  DATE=$(date)
  STARTTIME=$(date +%s);
  echo
  echo "Starting next crawl cycle at: $DATE"
  
  if [ "$ENABLE_SEED_DOWNLOAD" -eq "1" ]; then
    echo "Downloading seed file"
    wget -O /tmp/seed.txt "$SEED_URL" &&
    mv /tmp/seed.txt inrev/superseed.txt || {
      echo "Downloading seed failed, using old one";
    }
  else
    echo "Using local seeds"
  fi

  if [ "$ENABLE_REGEX_DOWNLOAD" -eq "1" ]; then
    echo "Downloading regex rules"
    for (( depth=1; depth<=$MAXDEPTH; depth++ )); do
      F=${depth}.regex-urlfilter.txt
      wget -O /tmp/$F "$REGEX_URL$depth" &&
        mv /tmp/$F inrev/ || {
        echo "Downloading $F failed, using old one";
        break;
      }
    done 
  else
    echo "Using local regexes"
  fi

  SIZE=$(wc -l inrev/superseed.txt | awk '{ print $1}')
  echo "Using inrev/superseed.txt as seed, total: $SIZE"
  ./bin/hadoop fs -mkdir -p /urls
  ./bin/hadoop fs -put -f inrev/superseed.txt /urls/seed.txt
  ./inrev/single-crawler.sh /urls/ cs "$SOLR_URL" 2 || {
   echo "Nutch processing failed, sending mail";
    echo "Nutch processing failed in $(hostname)" | mail -s "NUTCH PROCESS FAILED" $EMAILS;
};
 
  ENDTIME=$(date +%s);

  CYCLETIME=$((ENDTIME - STARTTIME));

  CYCLETIMEINHR=$((CYCLETIME / 3600));

  echo "Cycle time is $CYCLETIMEINHR Hours";


  if [ "$ENABLE_ALERT" -eq "1" ]; then
    if [[ $CYCLETIMEINHR -ge $MAX_CYCLE_TIME_HRS ]]; then
      echo "Nutch cycle time is more than $MAX_CYCLE_TIME_HRS hours in $(hostname), sending mail";
      echo "Nutch cycle time is more than $MAX_CYCLE_TIME_HRS hours in $(hostname)" | mail -s "NUTCH CYCLE TIME" $EMAILS;
    fi
  #else
    # send no alert
  fi


  echo "Sleeping for $CYCLE_SLEEP_SECS"
  sleep $CYCLE_SLEEP_SECS
done
