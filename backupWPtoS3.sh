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

export IFS=";"
for i in $sourcedirs; do
  echo 'compressing '$sourcedir' to '$destdir'/'${i///}'-'$timestamp'.zip'
  cd $i
  zip -r $destdir/${i///}-$timestamp.zip *
done

echo "dumping $dbname sql database"
mysqldump -u$dbuser -p$dbpass $dbname > $destdir/database.sql

echo "appending sql database to varwww-$timestamp.zip"
cd $destdir
zip -um varwww-$timestamp.zip database.sql

for i in $sourcedirs; do
  echo 'uploading '${i///}'-'$timestamp'.zip to S3'
  move2s3=$(aws s3 mv $destdir/${i///}-$timestamp.zip s3://$S3bucket 2>&1)
done

if [ $? != 0 ]; then
  aws sns publish --topic-arn $SNSarn --subject "AWS personal backup FAILED" --message "$move2s3"
else
  aws sns publish --topic-arn $SNSarn --subject "AWS personal backup DONE" --message "$move2s3"
fi
