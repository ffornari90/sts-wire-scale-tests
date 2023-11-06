#!/usr/bin/python3

import boto3
import os
import sys
import subprocess
import numpy as np
import certifi
import ssl
from urllib.request import build_opener, Request, ProxyHandler, HTTPSHandler
context=ssl.create_default_context(cafile=certifi.where())
https_handler = HTTPSHandler(context=context)

#boto3.set_stream_logger(name='botocore')

if len(sys.argv) < 2:
    print("No arguments provided.")
    sys.exit(1)

try:
    arg1 = int(sys.argv[1])
except ValueError:
    print("First argument cannot be converted to an integer.")
    sys.exit(1)

try:
    myfullpath = os.path.dirname(os.path.realpath(__file__))
except NameError:
    myfullpath = os.path.abspath(os.path.curdir)

index = np.arange(1, 1 + int(sys.argv[1]), 1)

audience = 'https://wlcg.cern.ch/jwt/v1/any'
endpoint = 'https://rgw.90.147.174.123.myip.cloud.infn.it'
iam_host = '131.154.96.40.myip.cloud.infn.it'
role_name = 'S3AccessIAMDouble'
iam_url = 'https://' + iam_host + '/'
role_arn = 'arn:aws:iam:::role/' + role_name
region = 'default'

for i in index:
    client = 'client%s' % i
    process = myfullpath + '/get-access-token.sh ' + str(i) + ' ' + iam_url + ' ' + audience
    token = subprocess.check_output(('sh', '-c', process)).strip().decode('utf-8')
    bucket_name = client

    sts_client = boto3.client('sts',
        endpoint_url=endpoint,
        region_name=region,
    )

    response = sts_client.assume_role_with_web_identity(
        RoleArn=role_arn,
        RoleSessionName=role_name,
        DurationSeconds=3600,
        WebIdentityToken=token
    )

    s3client = boto3.client('s3',
        aws_access_key_id = response['Credentials']['AccessKeyId'],
        aws_secret_access_key = response['Credentials']['SecretAccessKey'],
        aws_session_token = response['Credentials']['SessionToken'],
        endpoint_url=endpoint,
        region_name=region,
    )

    s3bucket = s3client.create_bucket(Bucket=bucket_name)

    s3list = s3client.list_buckets()
    print(s3list['Buckets'])
