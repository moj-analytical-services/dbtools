#' Convert an Athena type to an Arrow type
#'
#' @param t A string giving an Athena type
#'
#' @return An Arrow type
#' @export
#'
#' @see https://docs.aws.amazon.com/athena/latest/ug/data-types.html
#' @see https://arrow.apache.org/docs/r/reference/data-type.html
convert_athena_type_to_arrow <- function(t) {
  # Regular expression matches either e.g. decimal(10) or decimal(10, 5)
  decimal_match <- stringr::str_match(
    t,
    "decimal\\(([:digit:]+)(\\s*,\\s*([:digit:]+))?\\)"
  )
  if (!is.na(decimal_match[1])) {
    precision <- as.numeric(decimal_match[2])
    # Set scale to default 0 if not present
    scale <- ifelse(is.na(decimal_match[4]), 0, as.numeric(decimal_match[4]))
    return(arrow::decimal(precision, scale))
  }

  switch(
    t,
    "boolean" = arrow::bool(),
    "tinyint" = arrow::int8(),
    "smallint" = arrow::int16(),
    "int" = arrow::int32(),
    "integer" = arrow::int32(),
    "bigint" = arrow::int64(),
    "double" = arrow::float64(),
    "float" = arrow::float32(),
    "char" = arrow::string(),
    "string" = arrow::string(),
    "binary" = arrow::binary(),
    "date" = arrow::date32(),
    "timestamp" = arrow::timestamp(unit="ms", timezone="UTC"),
    arrow::string()
  ) %>% return
}


#' Send an SQL query to Athena and receive a data frame.
#'
#' @param sql An SQL query
#'
#' @return Dataframe
#' @export
#'
#' @examples
#' `df <- dbtools::read_sql_query('select * from my_db.my_table)`
read_sql_query <- function(sql) {
  query_id <- dbtools.env$pydb$start_query_execution(sql)
  dbtools.env$pydb$wait_query(query_id)
  athena_status <- dbtools.env$pydb$get_query_execution(query_id)
  athena_client <- dbtools.env$boto3$client('athena')
  response <- dbtools.env$athena_client$get_query_results(
    QueryExecutionId=query_id
  )

  if (athena_status$Status$State == 'FAILED') {
    stop('SQL query failed with response error;\n',
         athena_status$Status$StateChangeReason)
  }

  # Create arrow schema as a list of arrow::Fields
  schema <- list()
  for (col_info in response$ResultSet$ResultSetMetadata$ColumnInfo) {
    schema <- append(
      schema,
      list(arrow::field(col_info$Name,
                        convert_athena_type_to_arrow(col_info$Type)))
    )
  }

  df <- arrow::read_csv_arrow(
    athena_status$ResultConfiguration$OutputLocation,
    schema=schema,
    convert_options=arrow::CsvConvertOptions$create(strings_can_be_null=TRUE)
  )
  return(df)
}

#' @description Uses boto3 (in python) to send an sql query to athena and return an R dataframe, tibble or data.table based on user preference.
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
  if (return_df_as == "tibble") {
    return(tibble::as_tibble(df))
  } else if (return_df_as == "data.table") {
    return(data.table::as.data.table(df))
  } else {
    return(df)
  }
}