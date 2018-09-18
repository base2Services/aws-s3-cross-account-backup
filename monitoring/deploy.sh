#!/bin/bash
set -e

while getopts ":b:k:s:m:" opt; do
  case $opt in
    m)
      MODE=$OPTARG
      ;;
    s)
      SOURCEBUCKET=$OPTARG
      ;;
    b)
      MONITORBUCKET=$OPTARG
      ;;
    k)
      KEY=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ -z ${KEY+x} ]; then
  KEY="S3SyncMonitorFile"
fi

if [ -z ${MODE+x} ]; then
  echo "select the monitoring mode -m [check,create]"
  exit 1
fi

if [ -z ${MONITORBUCKET+x} ]; then
  echo "Monitored s3 source sync bucket not set with -b"
  exit 1
fi

if [ -z ${SOURCEBUCKET+x} ]; then
  echo "s3 cloudformation source bucket not set with -s"
  exit 1
fi

echo "packaging lambdas"
zip monitoring.zip checkFile.py createFile.py

echo "packaging cloudformation"
aws cloudformation package \
  --force-upload \
  --template-file checkFile.yaml \
  --s3-bucket $SOURCEBUCKET \
  --s3-prefix cloudformation/s3FileSyncMonitor \
  --output-template-file packaged-checkFile.yaml

echo "updating/creating cloudformation stack s3FileSyncMonitor$MODE"
aws cloudformation deploy \
  --template-file ./packaged-checkFile.yaml \
  --parameter-overrides Bucket=$MONITORBUCKET Key=$KEY MonitoringMode=$MODE \
  --stack-name s3FileSyncMonitor$MODE \
  --capabilities CAPABILITY_IAM
