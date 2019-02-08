#' delete_object
#'
#'@description uses boto3 (in python) to delete an S3 object (used by read_sql function to clean up after itself)
#'
#'@import reticulate
#'
#'@details Will send an SQL query to athena and wait for it to complete. Once the query has completed the resulting sql query will be read using read.csv (base R), read_csv (readr) or fread (data.table).
#' Function returns dataframe. If needing more a more bespoke or self defined data reading function and arguments use dbtools::get_athena_query_response to send an SQL query and return the s3 path to data in csv format.
#'
#'@param bucket A string specifying the s3 bucket name
#'
#'@param key File path to the s3 object

#'@examples
#'# delete a file from S3
#'# (note this is not exported so have to use tripple colon)
#'dbtools:::delete_object('my_bucket', 'path/to/file.csv')

delete_object <- function(bucket, key){
  python_script <- system.file("extdata", "boto_utils.py", package = "dbtools")
  reticulate::source_python(python_script)
  s3tools::get_credentials()
  delete_object(bucket=bucket, key=key)
}

get_iam_role <- function(){
  user <- Sys.getenv("USER")
  if(user==""){
    stop("Error could not find username in env vars. Please raise an issue on the Github repo for dbtools.")
  }
  iam_role <- paste0("alpha_user_", user)
  return(iam_role)
}

