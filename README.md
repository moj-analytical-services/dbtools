# dbtools

## About

A package that is used to run SQL queries configured for the 
Analytical Platform. This package is a [reticulated](https://rstudio.github.io/reticulate/) 
wrapper around [pydbtools](https://github.com/moj-analytical-services/pydbtools) 
which uses AWS Wrangler's Athena module but adds additional functionality 
(like Jinja templating, creating temporary tables) and alters some configuration 
to our specification.

Alternatively you probably want to use 
[Rdbtools](https://github.com/moj-analytical-services/Rdbtools), which has the 
advantages of supporting `dbplyr` and being R-native, so there's no messing with `reticulate` 
and Python which cause endless problems.

## Installation

Run the following commands in the R console.  

```R
# Set up the project to use renv, if not already done
renv::init()
# Tell renv that Python will be used
renv::use_python()
# Install the reticulate library to interface with Python
renv::install("reticulate")
# Install the Python library pydbtools
reticulate::py_install("pydbtools")
# Install dbtools
renv::install("moj-analytical-services/dbtools")
```

## Quickstart guide

There is a [vignette](doc/dbtools.pdf) with more details but the following
describes the basics of the package.

### Read an SQL Athena query into an R dataframe

```r
library(dbtools)

df <- read_sql_query("SELECT * from a_database.table LIMIT 10")
```

### Run a query in Athena

```r
response <- dbtools::start_query_execution_and_wait(
  "CREATE DATABASE IF NOT EXISTS my_test_database"
)
```

### Create temporary tables to do further separate SQL queries on later

```r
dbtools::create_temp_table(
  "SELECT a_col, count(*) as n FROM a_database.table GROUP BY a_col", 
  table_name="temp_table_1"
)
df <- dbtools::read_sql_query("SELECT * FROM __temp__.temp_table_1 WHERE n < 10")
```

### Delete databases, tables and partitions together with the data on S3

```r
dbtools::delete_partitions_and_data(
  database='my_database', 
  table='my_table', 
  expression='year = 2020 or year = 2021'
)
dbtools::delete_table_and_data(database='my_database', table='my_table')
dbtools::delete_database('my_database')

# These can be used for temporary databases and tables.
dbtools::delete_table_and_data(database='__temp__', table='my_temp_table')
```

### Use Jinja templating to inject arguments into your SQL

```r
sql_template <- "SELECT * FROM {{ db_name }}.{{ table }}"
sql <- dbtools::render_sql_template(sql_template, {"db_name": db_name, "table": "department"})
df <- dbtools::read_sql_query(sql)

cat("SELECT * FROM {{ db_name }}.{{ table_name }}", file="tempfile.sql")
sql <- dbtools::get_sql_from_file("tempfile.sql", jinja_args={"db_name": db_name, "table_name": "department"})
dbtools::read_sql_query(sql)
```

#### Changelog:

## 3.0.0 - 2022-02-03

- No longer dependent on s3tools
- Wraps `pydbtools` functions

## 2.0.3 - 2020-04-29

- Fixes prompts to install miniconda - now automatically uses main Analytical Platform Conda Python, based on sys path

## 2.0.2 - 2019-06-14

- Fixed issue where credentials would not refresh
- Is now dependant on `pydbtools` package
- SQL queries like `SHOW COLUMNS FROM db.table` now work for `read_sql` and return a df.

## 2.0.1 - 2019-04-23

- Updated the version in the DESCRIPTION file to the correct version

## v2.0.0 - 2019-02-08

- Removed input parameters `bucket` and `output_folder` from `read_sql` and `get_athena_query_response` functions. New section to README named 'Under The Hood' explains why.
- Note package now requires the group policy `StandardDatabaseAccess` to be attached to the role that needs to use this package. 

## v1.0.0 - 2019-01-14

- Added function `read_sql` which reads an SQL query directly into an R dataframe. See R documentation (i.e. `?read_sql`)
- Input parameter `out_path` in function `get_athena_query_response` has been replaced by two input parameters `bucket` and `output_folder`. E.g. If your `out_path="s3://my-bucket/__temp__"` then the new input params are `bucket=my-bucket` and `output_folder=__temp__`. Note that ` output_folder` defaults to value `__athena_temp__` it is recommended that you leave this unchanged.

## v0.0.2 - 2018-10-12

- `timeout` is now an input parameter to `get_athena_query_response` if not set there is no timeout for the athena query.
- `get_athena_query_response` will now print out the athena_client response if the athena query fails.

## v0.0.1 - First Release
