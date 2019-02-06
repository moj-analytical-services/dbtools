import boto3

def delete_object(bucket, key):
    s3_client = boto3.client('s3')
    s3_client.delete_object(Bucket=bucket, Key=key)
