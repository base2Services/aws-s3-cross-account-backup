#!/bin/bash
set -e

OPTIONAL_PARAMETERS=""

while getopts ":s:b:k:" opt; do
  case $opt in
    s)
      SOURCE_BUCKET=$OPTARG
      ;;
    b)
      BUCKET_LIST=$OPTARG
      ;;
    k)
      OPTIONAL_PARAMETERS="BucketSuffix=$OPTARG"
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

if [ -z ${SOURCE_BUCKET+x} ]; then
  echo "set source s3 bucket -s"
  exit 1
fi

if [ -z ${BUCKET_LIST+x} ]; then
  echo "set comma delimited list of s3 buckets to backup -b"
  exit 1
fi

echo "packaging cloudformation"
aws cloudformation package \
  --force-upload \
  --template-file template.yaml \
  --s3-bucket $SOURCE_BUCKET \
  --s3-prefix cloudformation/shelvery \
  --output-template-file packaged-template.yaml

echo "updating/creating cloudformation stack shelvery"
aws cloudformation deploy \
  --force-upload \
  --no-fail-on-empty-changeset \
  --template-file ./packaged-template.yaml \
  --stack-name s3-cross-account-backup \
  --parameter-overrides S3BackupBucketList=$BUCKET_LIST $OPTIONAL_PARAMETERS \
  --capabilities CAPABILITY_IAM
