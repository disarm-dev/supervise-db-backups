#!/bin/sh
DIR=`date +%m%d%y`
TOP=./db_backups
DEST=$TOP/$DIR

mkdir -p $DEST
# mongodump -h <your_database_host> -d <your_database_name> -u <username> -p <password> -o $DEST
mongodump -d douma_production -o $DEST >out 2>err

if [ $? -eq  1 ]; then
  echo "We have an error"
fi

# Potentially dangerous, beware
# Note to self, don't name variables $ROOT, almost wiped my laptop....
# find $TOP/* -type d -ctime +30 -exec rm -rf {} \;
