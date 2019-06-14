import boto3
from botocore.credentials import InstanceMetadataProvider, InstanceMetadataFetcher

def delete_object(bucket, key):
    rn = "eu-west-1"
    provider = InstanceMetadataProvider(
        iam_role_fetcher=InstanceMetadataFetcher(timeout=1000, num_attempts=2)
    )
    creds = provider.load().get_frozen_credentials()
    s3_client = boto3.client(
      "s3",
      region_name=rn,
      aws_access_key_id=creds.access_key,
      aws_secret_access_key=creds.secret_key,
      aws_session_token=creds.token,
    )
    s3_client.delete_object(Bucket=bucket, Key=key)
