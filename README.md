# AWS S3 cross account backup

## Environment Variables

- `BUCKETS` - comma delimited list of s3 buckets
- `BUCKET_SUFFIX` - suffix of backup s3 buckets, defaults to `backup`
- `SNS_TOPIC` - sns topic to send notifications
- `SNS_ERROR_TOPIC` - sns topic to receive only errors. If not set all notifications including errors get sent to `SNS_TOPIC`

## Deploy SAM template

1. Create a source bucket for the sam package

2. create backup buckets in s3 with name `${SOURCE_BUCKET}.${BUCKET_SUFFIX}` and enable versioning/encryption if required

3. add bucket policy to source bucket

```json
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Sid": "databunkerListBucket",
         "Effect": "Allow",
         "Principal": {
            "AWS": "arn:aws:iam::Account-ID:root"
         },
         "Action": [
            "s3:GetBucketLocation",
            "s3:ListBucket"
         ],
         "Resource": [
            "arn:aws:s3:::source-bucket"
         ]
      },
      {
         "Sid": "databunkerGetObjects",
         "Effect": "Allow",
         "Principal": {
            "AWS": "arn:aws:iam::Account-ID:root"
         },
         "Action": [
            "s3:GetObject"
         ],
         "Resource": [
            "arn:aws:s3:::source-bucket/*"
         ]
      }
   ]
}

```

4. Setup you aws credentials and set the region

    ```bash
    export AWS_PROFILE=profile
    export AWS_DEFAULT_REGION=ap-southeast-2
    ```

5. Run the `deploy.sh` script with the options to deploy the template in the target account.

    - `-s` [required] source bucket to deploy the sam package to
    - `-b` [required] comma delimited list of s3 buckets
    - `-k` [optional] suffix of backup s3 buckets, defaults to `backup`

## Monitoring

This check can be monitored using the SAM template in the [monitoring](monitoring/README.md) directory
