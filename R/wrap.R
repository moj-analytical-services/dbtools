#' Create a temporary table
#'
#' @param sql: The SQL table you want to create a temp table out of. Should
#'   be a table that starts with a WITH or SELECT clause.
#' @param table_name The name of the temp table you wish to create
#' @param region_name Name of the AWS region you want to run queries on.
#'   Defaults to pydbtools.utils.aws_default_region (which if left unset is
#'   "eu-west-1").
#'
#' @export
#'
#' @examples
#' `dbtools::create_temp_table("SELECT a_col, count(*) as n FROM a_database.table GROUP BY a_col", table_name="temp_table_1")`
create_temp_table <- function(sql, table_name, region_name) {
  dbtools.env$pydb$create_temp_table(sql, table_name, region_name=region_name)
}

#' Show the list of columns, including partition columns: 'DESCRIBE table;'.
#'
#' @param table Table name
#' @param database AWS Glue/Athena database name
#'
#' @return DataFrame filled by formatted infos.
#' @export
#'
#' @examples
#' `df_table = dbtools::describe_table(table='my_table', database='my_db')`
describe_table <- function(table, database) {
  dbtools.env$pydb$describe_table(table, database)
}

#' Get the data type of all columns queried.
#'
#' @param query_id Athena query execution ID
#'
#' @return List with all data types
#' @export
#'
#' @examples
#' `dbtools::get_query_columns_types('query-execution-id')`
get_query_columns_types <- function(query_id) {
  dbtools.env$pydb$get_query_columns_types(query_id)
}

#' Fetch query execution details.
#'
#' @param query_id Athena query execution ID
#'
#' @return List with the get_query_execution response.
#' @export
#'
#' @examples
#' `res <- dbtools::get_query_execution(query_id='query-execution-id')`
get_query_execution <- function(query_id) {
  dbtools.env$pydb$get_query_execution(query_id)
}


#' Run the Hive's metastore consistency check: 'MSCK REPAIR TABLE table;'.
#'
#' Recovers partitions and data associated with partitions.
#' Use this statement when you add partitions to the catalog.
#' It is possible it will take some time to add all partitions.
#' If this operation times out, it will be in an incomplete state
#' where only a few partitions are added to the catalog.
#'
#' @param table Table name
#' @param database AWS Glue/Athena database name
#'
#' @return Query final state ('SUCCEEDED', 'FAILED', 'CANCELLED')
#' @export
#'
#' @examples
#' `query_final_state = dbtools::repair_table(table='...', database='...')`
repair_table <- function(table, database) {
  dbtools.env$pydb$repair_table(table, database)
}

#' Generate the query that created a table: 'SHOW CREATE TABLE table;'.
#'
#' @param table Table name
#' @param database AWS Glue/Athena database name
#'
#' @return The query that created the table
#' @export
#'
#' @examples
#' `df_table = dbtools::show_create_table(table='my_table', database='my_db')`
show_create_table <- function(table, database) {
  dbtools.env$pydb$show_create_table(table, database)
}

#' Start a SQL Query against AWS Athena
#'
#' @param sql SQL query
#' @param wait Default FALSE, indicates whether to wait for the query to finish and return a dictionary with the query execution response.
#'
#' @return Query execution ID if `wait` is set to `False`, list with the get_query_execution response otherwise.
#' @export
start_query_execution <- function(sql, wait=FALSE) {
  dbtools.env$pydb$start_query_execution(sql, wait)
}

#' Stop a query execution
#'
#' @param query_id Athena query execution ID
#'
#' @export
stop_query_execution <- function(query_id) {
  dbtools.env$pydb$stop_query_execution(query_id)
}

#' Wait for a query to end.
#'
#' @param query_id Athena query execution ID
#'
#' @return List with the get_query_execution response
#' @export
#'
#' @examples
#' `res <- dbtools::wait_query(query_id)`
wait_query <- function(query_id) {
  dbtools.env$pydb$wait_query(query_id)
}

#' Calls start_query_execution followed by wait_query.
#'
#' @param sql An SQL string. Which works with __TEMP__ references.
#'
#' @return List with the get_query_execution response.
#' @export
#'
#' @examples
#' `res <- dbtools::start_query_execution_and_wait('select * from __temp__.my_table')`
start_query_execution_and_wait <- function(sql) {
  dbtools.env$pydb$start_query_execution_and_wait(sql)
}

#' Deletes partitions and the underlying data on S3 from an Athena
#' database table matching an expression.
#'
#' @param database The database name.
#' @param table The table name.
#' @param expression The expression to match.
#'
#' @see https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/glue.html#Glue.Client.get_partitions
#' @export
#'
#' @examples
#' `dbtools::delete_partitions_and_data("my_database", "my_table", "year = 2020 and month = 5")`
delete_partitions_and_data <- function(database, table, expression) {
  dbtools.env$pydb$delete_partitions_and_data(database, table, expression)
}

#' Deletes both a table from an Athena database and the underlying data on S3.
#'
#' @param database The database name.
#' @param table The table name.
#'
#' @export
#'
#' @examples
#' `dbtools::delete_table_and_data("__temp__", "my_table")`
delete_table_and_data <- function(database, table) {
  dbtools.env$pydb$delete_table_and_data(database, table)
}

#' Deletes both an Athena database and the underlying data on S3.
#'
#' @param database Database name
#'
#' @export
delete_database_and_data <- function(database) {
  dbtools.env$pydb$delete_database_and_data(database)
}

#' Read in an SQL file and inject arguments with Jinja (if given params).
#'
#' @param filepath A filepath to your SQL file.
#' @param jinja_args If not NULL, will pass the read
#'   in SQL file through a jinja template to render the template.
#'   Otherwise will just return the SQL file as is. Defaults to NULL.
#'
#' @return
#' @export
#'
#' @examples
get_sql_from_file <- function(filepath, jinja_args=NULL) {
  dbtools.env$pydb$get_sql_from_file(filepath, jinja_args)
}

#' Takes an SQL query and injects arguments with Jinja.
#'
#' @param sql An SQL query
#' @param jinja_args Arguments that are referenced in the SQL file
#'
#' @export
render_sql_template <- function(sql, jinja_args) {
  dbtools.env$pydb$render_sql_template(sql, jinja_args)
}
