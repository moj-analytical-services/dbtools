#' get_athena_query_response
#'
#'@description uses boto3 (in python) to send an sql query to athena and return the resulting data's path in s3 and meta data
#'
#'@import reticulate s3tools
#'
#'@export
#'
#'@details Will send an SQL query to athena and wait for it to complete. Once the query has completed the funtion will return a list containing the s3 path to your athena query and meta data about the output data
#'
#'@param sql_query A string specifying the SQL query you want to send to athena. See packages github readme for info on the flavour of SQL Athena uses.
#'
#'@param bucket The s3 bucket the query results will be written into.  You must have read and write permissions to this folder.
#'
#'@param output_folder The folder path where you want your athena query to be written to. If not specified the output folder is "__athena_temp__" which is recommended.
#'
#'@param return_athena_types Specifies if the list describing the data's meta data types should be defined using athena datatypes (TRUE) or using the data engineering team's generic metadata types (FALSE). If not specified the default value of this input parameter is set to FALSE.
#'
#'@param timeout Specifies How long you want your sql query to wait before it gives up (in seconds). Default parameter is NULL which will mean SQL query will not timeout and could wait forever if an issue occured.
#'
#'@return A list with two keys. [1] s3_path : a string pointing to the s3 path of the athena query. [2] meta : a list that has the name and type of each column in of the data in the s3_path. Can be used to get correct data types of your output when read in to R (note the order of the columns matches the order they appear in the data).
#'
#'@examples
#'# Read an sql query using readr::read_csv
#'response <- dbtools::get_athena_query_response("SELECT * from crest_v1.flatfile limit 10000", "my-bucket")
#'
#'# print out path to athena query output (as a csv)
#'print(response$s3_path)
#'
#'# print out meta data
#'print(response$meta)
#'
#'# Read in data using whatever csv reader you want
#'s3_path_stripped = gsub("s3://", "", response$s3_path)
#'df <- s3tools::read_using(FUN = read.csv, s3_path=s3_path_stripped)

get_athena_query_response <- function(sql_query, return_athena_types=FALSE, timeout = NULL){

  # Annoyingly I think you have to pull it in as the source_python function doesn't seem to be exported properly
  # require(reticulate)

  python_script <- system.file("extdata", "get_athena_query_response.py", package = "dbtools")
  reticulate::source_python(python_script)
  s3tools::get_credentials()
  response <- get_athena_query_response(sql_query=sql_query, return_athena_types=return_athena_types, timeout=timeout)
  return(response)
}
