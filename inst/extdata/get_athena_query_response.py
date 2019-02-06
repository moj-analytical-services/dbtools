import boto3
import pandas as pd
import io
import time
import os

def get_athena_query_response(sql_query, return_athena_types = False, timeout = None) :

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

    # Get role specific path for athena output
    bucket = "alpha-athena-query-dump"
    user = os.getenv('USER', '')
    if user == '':
      raise ValueError('ENV variable USER could not be found. Please raise an issue on the dbtools github repo')

    iam_client=boto3.client('iam')
    role = iam_client.get_role(RoleName='alpha_user_'+user)
    out_path = os.path.join('s3://', bucket, role['Role']['RoleId'], "__athena_temp__/")

    if out_path[-1] != '/':
      out_path += '/'

    # Run the athena query
    athena_client = boto3.client('athena', 'eu-west-1')
    response = athena_client.start_query_execution(
        QueryString=sql_query,
        ResultConfiguration={
            'OutputLocation': out_path,
      }
    )

    sleep_time = 2
    counter = 0
    while True :
        athena_status = athena_client.get_query_execution(QueryExecutionId = response['QueryExecutionId'])
        if athena_status['QueryExecution']['Status']['State'] == "SUCCEEDED" :
            break
        elif athena_status['QueryExecution']['Status']['State'] in ['QUEUED','RUNNING'] :
            # print('waiting...')
            time.sleep(sleep_time)
        elif athena_status['QueryExecution']['Status']['State'] == 'FAILED' :
            raise ValueError("athena failed - response error:\n {}".format(athena_status['QueryExecution']['Status']['StateChangeReason']))
        else :
            raise ValueError("athena failed - unknown reason (printing full response):\n {athena_status}".format(athena_status))

        counter += 1
        if timeout :
          if counter*sleep_time > timeout :
              raise ValueError('athena timed out')

    result_response = athena_client.get_query_results(QueryExecutionId=athena_status['QueryExecution']['QueryExecutionId'], MaxResults=1)
    s3_path = athena_status['QueryExecution']['ResultConfiguration']['OutputLocation']
    if return_athena_types :
        meta = [{'name':c['Name'], 'type' : c['Type']} for c in result_response['ResultSet']['ResultSetMetadata']['ColumnInfo']]
    else :
        meta = [{'name':c['Name'], 'type' : type_dictionary[c['Type']]} for c in result_response['ResultSet']['ResultSetMetadata']['ColumnInfo']]

    return {'s3_path' : s3_path, 'meta' : meta}

