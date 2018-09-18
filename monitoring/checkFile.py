#!/usr/bin/env python
import boto3
import os
from datetime import datetime

def lambda_handler(event, context):
    bucket = os.environ['Bucket']
    key = os.environ['Key']
    region = os.environ['Region']
    date = datetime.now().strftime('%Y-%m-%d')
    print("Checking for " + date + " in " + bucket + "/" + key)
    s3 = boto3.resource('s3')
    object = s3.Object(bucket, key)
    stamp = object.get()['Body'].read().decode('utf-8')
    print("Found " + stamp + " in " + bucket + "/" + key)
    if stamp == date:
        print("Writing CloudWatch Metric under s3FileSyncMonitor Namespace")
        cloudwatch = boto3.client('cloudwatch', region_name=region)
        cloudwatch.put_metric_data(
            MetricData=[
                {
                    'MetricName': 'Sync',
                    'Dimensions': [
                        {
                            'Name': 'File',
                            'Value': key
                        },
                        {
                            'Name': 'Bucket',
                            'Value': bucket
                        },
                    ],
                    'Value': 1
                },
            ],
            Namespace='s3FileSyncMonitor'
        )
