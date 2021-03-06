#!/bin/bash

#quick and dirty script to full backup wordpress and other dirs to S3 and send SNS alert

timestamp=`date '+%d%m%Y'`
sourcedirs="/path/2/backup;/path2/2/backup;/path3/2/backup"
destdir=/tmp
dbname="dbname"
dbuser="dbuser"
dbpass="dbpass"
S3bucket="S3bucket"
SNSarn="SNSarn"

error_file="/tmp/backup.log"

export IFS=";"
for i in $sourcedirs; do
  echo 'compressing  '$destdir'/'${i///}'-'$timestamp'.zip'
  cd $i
  zip -r $destdir/${i///}-$timestamp.zip *
done

echo "dumping $dbname sql database"
mysqldump -u$dbuser -p$dbpass $dbname > $destdir/database.sql

echo "appending sql database to varwww-$timestamp.zip"
cd $destdir
zip -um varwww-$timestamp.zip database.sql


echo "appending opendkim.conf etcopendkim-$timestamp.zip"
zip -u etcopendkim-$timestamp.zip /etc/opendkim.conf

echo 'moving files to S3'
/usr/local/bin/aws s3 mv $destdir/ s3://$S3bucket --recursive --exclude "*" --include "*.zip"

if [ $? != 0 ]; then
  /usr/local/bin/aws sns publish --topic-arn $SNSarn --subject "AWS personal backup FAILED" --message "FAIL"
else
  /usr/local/bin/aws sns publish --topic-arn $SNSarn --subject "AWS personal backup DONE" --message "OK"
fi
