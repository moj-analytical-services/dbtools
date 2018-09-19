import boto3 
import pandas as pd
import io
import time 

def get_athena_query_response(sql_query, return_athena_types = False) :
  
    type_dictionary = {
        "char" : "character",
        "varchar" : "character",
        "integer" : "int",
        "bigint" : "long",
        "date" : "date",
        "timestamp" : "datetime",
        "boolean" : "boolean",
        "float" : "float",
        "double" : "double"
    }
  
    def s3_path_to_bucket_key(s3_path):
        """
        Splits out s3 file path to bucket key combination
        """
        s3_path = s3_path.replace("s3://", "")
        bucket, key = s3_path.split('/', 1)
        return bucket, key

    tmp_bucket = 'aws-athena-query-results-593291632749-eu-west-1'

    temp_folder = 's3://{}/'.format(tmp_bucket)
    athena_client = boto3.client('athena', 'eu-west-1')
    s3_client = boto3.client('s3')
    response = athena_client.start_query_execution(
        QueryString=sql_query,
        ResultConfiguration={
            'OutputLocation': temp_folder,
      }
    )
    
    sleep_time = 2
    timeout = 60
    counter = 0
    while True :
        athena_status = athena_client.get_query_execution(QueryExecutionId = response['QueryExecutionId'])
        if athena_status['QueryExecution']['Status']['State'] == "SUCCEEDED" :
            break
        elif athena_status['QueryExecution']['Status']['State'] in ['QUEUED','RUNNING'] :
            # print('waiting...')
            time.sleep(sleep_time)
        else :
            raise ValueError('athena failed')
        counter += 1
        
        if counter*sleep_time > timeout :
            raise ValueError('athena timed out')
    
    result_response = athena_client.get_query_results(QueryExecutionId=athena_status['QueryExecution']['QueryExecutionId'], MaxResults=1)
    s3_path = athena_status['QueryExecution']['ResultConfiguration']['OutputLocation']
    if return_athena_types :
        meta = [{'name':c['Name'], 'type' : c['Type']} for c in result_response['ResultSet']['ResultSetMetadata']['ColumnInfo']]
    else :
        meta = [{'name':c['Name'], 'type' : type_dictionary[c['Type']]} for c in result_response['ResultSet']['ResultSetMetadata']['ColumnInfo']]
    
    return {'s3_path' : s3_path, 'meta' : meta}

