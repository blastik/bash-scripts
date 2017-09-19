#!/bin/bash

#quick and dirty script to full backup wordpress to S3 and send SNS alert

timestamp=`date '+%d%m%Y'`
sourcedir=/var/www/
destdir=/tmp
dbname="value"
dbuser="value"
dbpass="value"
S3bucket="value"
SNSarn="value"

echo "compressing $sourcedir to $destdir/wordpress-backup-$timestamp.zip"
cd $sourcedir
zip -r $destdir/wordpress-backup-$timestamp.zip *

echo "dumping $dbname sql database"
mysqldump -u$dbuser -p$dbpass $dbname > $destdir/database.sql

echo "appending sql database to wordpress-backup-$timestamp.zip"
cd $destdir
zip -um wordpress-backup-$timestamp.zip database.sql

echo "uploading files to S3"
move2s3=$(/usr/local/bin/aws s3 mv $destdir/wordpress-backup-$timestamp.zip s3://$S3bucket 2>&1)
if [ $? != 0 ]; then
    /usr/local/bin/aws sns publish --topic-arn $SNSarn --subject "Wordpress backup FAILED" --message "$move2s3"
else
    /usr/local/bin/aws sns publish --topic-arn $SNSarn --subject "Wordpress backup DONE" --message "$move2s3"
fi
