#!/bin/bash

if [ -z ${BUCKETS} ]; then
  echo "ERROR: No buckets found..."
  exit 1
fi

IFS=', ' read -r -a BUCKET_ARRAY <<< "$BUCKETS"

for bucket in ${BUCKET_ARRAY[@]}; do
  echo "INFO: Backup for $bucket starting"
  if aws s3 sync s3://${bucket} s3://${bucket}.backup/; then
    STATUS="OK"
  else
    STATUS="FAILED"
  fi
  echo "INFO: Backup completed with status $STATUS"
  aws sns publish --topic-arn ${SNS_TOPIC} --message "{\"Operation\":\"S3BucketBackup\",\"Status\":\"${STATUS}\",\"BackupType\":\"S3\",\"Bucket\":\"$bucket\",\"Timestamp\":\"$(date +%Y%m%d-%H%M%S)\"}"
done

echo "INFO: done!"
