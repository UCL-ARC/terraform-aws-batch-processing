# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import json
import boto3
import os

client = boto3.client('stepfunctions')
s3 = boto3.client("s3")

sfnArn = os.environ["SFN_ARN"]
EFSMount = "/mnt"
TempDir = "/tmp"

def lambda_handler(event, context):
    local_temp_file = f"{TempDir}/file-name.zip"
    efs_file_path = f"{EFSMount}/s3_data.zip"

    records = [x for x in event.get('Records', []) if x.get('eventName') == 'ObjectCreated:Put']
    sorted_events = sorted(records, key=lambda e: e.get('eventTime'))
    latest_event = sorted_events[-1] if sorted_events else {}
    info = latest_event.get('s3', {})
    file_key = info.get('object', {}).get('key')
    bucket_name = info.get('bucket', {}).get('name')

    os.makedirs(TempDir, exist_ok=True)
    with open(local_temp_file, "wb") as f:
        s3.download_fileobj(bucket_name, file_key, f)

    os.system(f"cp {local_temp_file} {efs_file_path}")

    print(os.system(f"ls -la {EFSMount}"))
    response = client.start_execution(
        stateMachineArn=sfnArn,
        input=json.dumps(event)
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps(response,default=str)
    }
