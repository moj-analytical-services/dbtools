#' Send an SQL query to Athena and receive a dataframe.
#'
#' @param sql An SQL query
#'
#' @return Dataframe or tibble if the tibble library is loaded.
#' @export
#'
#' @examples
#' `df <- dbtools::read_sql_query('select * from my_db.my_table')`
read_sql_query <- function(sql) {
  # Download the dataframe result to a parquet temporary file as pandas and
  # reticulate are frequently incompatible, and load the data into R using
  # arrow.
  tmp_location <- tempfile(fileext=".parquet")
  dbtools.env$pydb$save_query_to_parquet(sql, tmp_location)
  df <- arrow::read_parquet(tmp_location)
  unlink(tmp_location)
  return(df)
}

#' Uses boto3 (in python) to send an sql query to athena and return an R dataframe, tibble or data.table based on user preference.
#'
#' @export
#'
#' @details Will send an SQL query to Athena and wait for it to complete. Once the query has completed the resulting sql query will be read using arrow.
#' Function returns dataframe. If needing more a more bespoke or self defined data reading function and arguments use dbtools::start_query_and_wait to send an SQL query and return the s3 path to data in csv format.
#'
#' @param sql_query A string specifying the SQL query you want to send to athena. See packages github readme for info on the flavour of SQL Athena uses.
#' @param return_df_as String specifying what the table should be returned as i.e. 'dataframe', 'tibble' (converts data using tibble::as_tibble) or 'data.table' (converts data using data.table::as.data.table). Default is 'tibble'. Not all tables returned are a DataFrame class.
#'
#' @return A table as a dataframe, tibble or data.table
#'
#' @examples
#' # Read an sql query returning a tibble
#' ```
#' df <- dbtools::read_sql(
#'   "SELECT * from crest_v1.flatfile limit 10000",
#'   return_df_as="tibble"
#' )
#' ```
read_sql <- function(sql_query, return_df_as="tibble") {
  df <- read_sql_query(sql_query)
  if (return_df_as == "dataframe") {
    return(as.data.frame(df))
  } else if (return_df_as == "data.table") {
    return(data.table::as.data.table(df))
  } else {
    return(tibble::as_tibble(df))
  }
}
