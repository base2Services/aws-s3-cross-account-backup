#!/usr/bin/env python
import boto3
import os
from datetime import datetime

def lambda_handler(event, context):
    bucket = os.environ['Bucket']
    key = os.environ['Key']
    date = datetime.now().strftime('%Y-%m-%d')
    print("Writing " + date + " to " + bucket + "/" + key)
    s3 = boto3.resource('s3')
    object = s3.Object(bucket, key)
    object.put(Body=date.encode())
