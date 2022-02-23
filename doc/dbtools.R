## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
devtools::load_all()

## ----setup--------------------------------------------------------------------
library(dbtools)

## -----------------------------------------------------------------------------
read_sql_query("select * from aws_example_dbtools.employees limit 5")

## -----------------------------------------------------------------------------
read_sql("select * from aws_example_dbtools.department limit 5",
         return_df_as="tibble")

## -----------------------------------------------------------------------------
read_sql("select * from aws_example_dbtools.sales limit 5",
         return_df_as="data.table")

## -----------------------------------------------------------------------------
sql <- "
SELECT employee_id, sum(sales) as total_sales
FROM aws_example_dbtools.sales
GROUP BY employee_id
"
create_temp_table(sql, table_name="total_sales")

## -----------------------------------------------------------------------------
sql <- "
SELECT e.employee_id, e.forename, e.surname, d.department_name
FROM aws_example_dbtools.employees AS e
LEFT JOIN aws_example_dbtools.department AS d
ON e.department_id = d.department_id
WHERE e.department_id = 1
"
create_temp_table(sql, table_name="sales_employees")

## -----------------------------------------------------------------------------
sql <- "
SELECT se.*, ts.total_sales
FROM __temp__.sales_employees AS se
INNER JOIN __temp__.total_sales AS ts
ON se.employee_id = ts.employee_id
"
read_sql_query(sql)

## -----------------------------------------------------------------------------
sql_template = "select * from {{ db_name }}.{{ table }} limit 10"
sql <- render_sql_template(sql_template, 
                           list(db_name="aws_example_dbtools",
                                table="department"))
sql

## -----------------------------------------------------------------------------
read_sql_query(sql)

## -----------------------------------------------------------------------------
sql <- render_sql_template(sql_template, 
                           list(db_name="aws_example_dbtools",
                                table="sales"))
read_sql_query(sql)

## -----------------------------------------------------------------------------
cat("SELECT * FROM {{ db_name }}.{{ table_name }}", file="tempfile.sql")

sql <- get_sql_from_file("tempfile.sql",
                         jinja_args=list(db_name="aws_example_dbtools",
                                         table_name="department"))
read_sql_query(sql)

## -----------------------------------------------------------------------------
sql <- "
CREATE DATABASE IF NOT EXISTS new_db_dbtools
COMMENT 'Example of running queries and insert into'
LOCATION 's3://alpha-everyone/dbtools/new_db/'
"

response <- start_query_execution_and_wait(sql)
response$Status$State

## -----------------------------------------------------------------------------
sql <- "
CREATE TABLE new_db_dbtools.sales_report WITH
(
    external_location='s3://alpha-everyone/dbtools/new_db/sales_report'
) AS
SELECT qtr as sales_quarter, sum(sales) AS total_sales
FROM aws_example_dbtools.sales
WHERE qtr IN (1,2)
GROUP BY qtr
"

response <- start_query_execution_and_wait(sql)
response$Status$State

## -----------------------------------------------------------------------------
sql <- "
INSERT INTO new_db_dbtools.sales_report
SELECT qtr as sales_quarter, sum(sales) AS total_sales
FROM aws_example_dbtools.sales
WHERE qtr IN (3,4)
GROUP BY qtr
"

response <- start_query_execution_and_wait(sql)
read_sql_query("select * from new_db_dbtools.sales_report") 

## -----------------------------------------------------------------------------
sql <- "
CREATE TABLE new_db_dbtools.daily_sales_report WITH
(
    external_location='s3://alpha-everyone/dbtools/new_db/daily_sales_report',
    partitioned_by = ARRAY['report_date']
) AS
SELECT qtr as sales_quarter, sum(sales) AS total_sales,
date '2021-01-01' AS report_date
FROM aws_example_dbtools.sales
GROUP BY qtr, date '2021-01-01'
"

response <- start_query_execution_and_wait(sql)
response$Status$State

## -----------------------------------------------------------------------------
sql <- "
INSERT INTO new_db_dbtools.daily_sales_report
SELECT qtr as sales_quarter, sum(sales) AS total_sales,
date '2021-01-02' AS report_date
FROM aws_example_dbtools.sales
GROUP BY qtr, date '2021-01-02'
"

response <- start_query_execution_and_wait(sql)
read_sql_query("select * from new_db_dbtools.daily_sales_report")

## -----------------------------------------------------------------------------
delete_partitions_and_data("new_db_dbtools", "daily_sales_report",
                           "report_date = '2021-01-02'")
read_sql_query("select * from new_db_dbtools.daily_sales_report")

## -----------------------------------------------------------------------------
delete_table_and_data("new_db_dbtools", "daily_sales_report")

## -----------------------------------------------------------------------------
delete_database_and_data("new_db_dbtools")

## ---- include=FALSE-----------------------------------------------------------
delete_database_and_data("aws_example_dbtools")

