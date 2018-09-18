#!/bin/bash

if [ -z ${BUCKETS} ]; then
  echo "ERROR: No buckets found..."
  exit 1
fi

if [ -z ${BUCKET_SUFFIX} ]; then
  BUCKET_SUFFIX="backup"
fi

START=$SECONDS
IFS=', ' read -r -a BUCKET_ARRAY <<< "$BUCKETS"

for bucket in ${BUCKET_ARRAY[@]}; do

  echo "INFO: Backup for $bucket starting"
  if aws s3 sync s3://${bucket} s3://${bucket}.${BUCKET_SUFFIX}/; then
    STATUS="OK"
  else
    STATUS="FAILED"
  fi
  MESSAGE="{\"Operation\":\"S3BucketBackup\",\"Status\":\"${STATUS}\",\"BackupType\":\"S3\",\"Bucket\":\"$bucket\",\"Timestamp\":\"$(date +%Y%m%d-%H%M%S)\"}"
  echo "INFO: Backup task finished with status $STATUS"

  if [ ! -z ${SNS_ERROR_TOPIC} && $STATUS == "FAILED" ]; then
    echo "INFO: Sending sns error notification to $SNS_ERROR_TOPIC\n$MESSAGE"
    aws sns publish --topic-arn ${SNS_ERROR_TOPIC} --message $MESSAGE
  elif [ ! -z ${SNS_TOPIC} ]; then
    echo "INFO: Sending sns notification to $SNS_TOPIC\n$MESSAGE"
    aws sns publish --topic-arn ${SNS_TOPIC} --message $MESSAGE
  fi

done

echo "INFO: Backup task complete\nduration: $((SECONDS-START)) seconds elapsed.."
