#' read_sql
#'
#'@description uses boto3 (in python) to send an sql query to athena and return an R dataframe, tibble or data.table based on user preference.
#'
#'@import reticulate s3tools readr data.table
#'
#'@export
#'
#'@details Will send an SQL query to athena and wait for it to complete. Once the query has completed the resulting sql query will be read using read.csv (base R), read_csv (readr) or fread (data.table).
#' Function returns dataframe. If needing more a more bespoke or self defined data reading function and arguments use dbtools::get_athena_query_response to send an SQL query and return the s3 path to data in csv format.
#'
#'@param sql_query A string specifying the SQL query you want to send to athena. See packages github readme for info on the flavour of SQL Athena uses.
#'
#'@param bucket The s3 bucket the query results will be written into.  You must have read and write permissions to this folder.
#'
#'@param output_folder The folder path where you want your athena query to be written to. If not specified the output folder is "__athena_temp__" which is recommended.
#'
#'@param return_df_as String specifying what the table should be returned as i.e. 'dataframe' (reads data using read.csv), 'tibble' (reads data using readr::read_csv) or 'data.table' (reads data using data.table::fread). Default is 'tibble'. Not all tables returned are a DataFrame class.
#' Only return_df_as set to 'tibble' maintains date and datetime formats. dataframe and data.table will convert date and datetimes to characters.
#'
#'@param timeout Specifies How long you want your sql query to wait before it gives up (in seconds). Default parameter is NULL which will mean SQL query will not timeout and could wait forever if an issue occured.
#'
#'@return A table as a Dataframe, tibble or data.table
#'
#'@examples
#'# Read an sql query using readr::read_csv i.e. returning a Tibble
#'df <- dbtools::read_sql("SELECT * from crest_v1.flatfile limit 10000", 'my-bucket')
#'df

read_sql <- function(sql_query, return_df_as='tibble', timeout = NULL){

  # Annoyingly I think you have to pull it in as the source_python function doesn't seem to be exported properly
  # require(reticulate)

  bucket <- "alpha-athena-query-dump"
  output_folder=paste0(dbtools:::get_iam_role(), "/__athena_temp__/")

  return_df_as <- tolower(return_df_as)
  if(!return_df_as %in% c('dataframe', 'tibble', 'data.table')){
    stop("input var return_df_as must be one of the following 'dataframe', 'tibble' or 'data.table'")
  }

  response <- dbtools::get_athena_query_response(sql_query=sql_query, bucket=bucket, output_folder=output_folder, return_athena_types=FALSE, timeout=timeout)
  s3_path_stripped <- gsub("s3://", "", response$s3_path)
  s3_key <- gsub(paste0(bucket,"/"), "", s3_path_stripped)

  data_conversion <- dbtools:::get_data_conversion(return_df_as)
  col_classes = list()
    for(m in response$meta){
      col_classes[[m$name]] = data_conversion[[m$type]]
    }
  col_classes_vec = unlist(col_classes)

  if(return_df_as == 'tibble'){
    #This is the best R work arround I could find to replicate Python's **kwargs...
    col_types = do.call(readr::cols, col_classes)
    df <- s3tools::read_using(FUN=readr::read_csv, s3_path=s3_path_stripped, col_names=TRUE, col_types=col_types)

  } else if(return_df_as == 'data.table'){
    dt_ver <- packageVersion("data.table")
    if(dt_ver < '1.11.8'){
      warning("Your version of data.table must be 1.11.8 or above please install a new version otherwise your outputs of type data.table may not convert data types properly.")
    }
    df <- s3tools::read_using(FUN=data.table::fread, s3_path=s3_path_stripped, header=TRUE, colClasses=col_classes_vec)
  } else {
    df <- s3tools::read_using(FUN=read.csv, s3_path=s3_path_stripped, header=TRUE, colClasses=col_classes_vec)
  }
  dbtools:::delete_object(bucket, s3_key)
  dbtools:::delete_object(bucket, paste0(s3_key, ".metadata"))
  return(df)
}
