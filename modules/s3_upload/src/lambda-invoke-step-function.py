# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import json
import boto3
import os

client = boto3.client('stepfunctions')
sfnArn = os.environ["SFN_ARN"]

def lambda_handler(event, context):

    response = client.start_execution(
        stateMachineArn=sfnArn,
        input=json.dumps(event)
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps(response,default=str)
    }
