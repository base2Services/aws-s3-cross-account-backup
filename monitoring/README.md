# AWS S3 cross account backup Monitoring

This monitoring creates a file in the monitored s3 bucket with a timestamp, then wait for the s3 sync to occur and check the timestamp in the file.\n
It is broken up into 2 modes to be deployed as 2 seperate cloudformation stacks using SAM\n

1. Create
  - creates the file with contents of a timestamp (UTC)

2. Check
  - once the sync has occurred checks the timestamp in the file and matches to current date
  - if timestamp is out of date trigger alarm and send a notification through sns

## Deploy SAM template

1. Setup you aws credentials and set the region

    ```bash
    export AWS_PROFILE=profile
    export AWS_DEFAULT_REGION=ap-southeast-2
    ```

2. Run the `deploy.sh` script with the options to deploy the template in the target account.

    - `-s` [required] source bucket to deploy the sam package to
    - `-b` [required] s3 bucket to monitor
    - `-m` [required] enable the required monitoring mode, `check` or `create`
    - `-k` [optional] name of the file monitoring creates, defaults to `S3SyncMonitorFile`
    - `-t` [optional] specify an existing sns topic arn
