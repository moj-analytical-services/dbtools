# dbtools

Users who have yet to migrate to the newer version of the Analytical 
Platform should refer to the [Legacy](#legacy) section below.

## About

A package that is used to run SQL queries configured for the 
Analytical Platform. This packages is a [reticulated](https://rstudio.github.io/reticulate/) 
wrapper around [pydbtools](https://github.com/moj-analytical-services/pydbtools) 
which uses AWS Wrangler's Athena module but adds additional functionality 
(like Jinja templating, creating temporary tables) and alters some configuration 
to our specification.

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

# Legacy

The information below applies to versions <3.0.0, and should be used by anyone 
on the older version of the Analytical Platform i.e. anyone using R3.*.

This is a simple package that lets you query databases using Amazon Athena and get the s3 path to the athena output (as a csv). This is significantly faster than using database drivers provided by Amazon, so might be a good option when pulling in large data. 

Note: this package works alongside user IAM policies on the Analytical-Platform and requires you to be added to be given a standard database access. If in our github organisation you will be able to access the repo to request standard database access [here](https://github.com/moj-analytical-services/data-engineering-database-access).

## Setup

This package uses the Python package [pydbtools](https://github.com/moj-analytical-services/pydbtools) under the hood. Make sure your R-Studio deployment is up to date and has Python 3.6 or higher installed. 

Before using dbtools you'll need to install pydbtools v2.0.2. Do this from the R terminal:

```
# in terminal
python -m pip install -U pydbtools==2.0.2
```

Then install dbtools itself. The best way to do this is via conda:

```
# in terminal
conda install -c moj-analytical-services r-dbtools 
```

Package requirements are:

- `s3tools` _(preinstalled)_
- `reticulate`
- `python` _(preinstalled - version 3.6 or higher)_

- `boto3` _(preinstalled)_
- `readr` _(preinstalled)_
- `data.table` _(version 1.11.8 or above)_

## Examples

The easiest way to read in the data:
```r
# returns SQL query with matching data types as a tibble
df = dbtools::read_sql("SELECT * from crest_v1.flatfile limit 10000")

# Read df as a data.table
dt = dbtools::read_sql("SELECT * from crest_v1.flatfile limit 10000", return_df_as = "data.table")
```

If you want to read in your data using a specific method
```r

### Read SQL query using your own read csv method
response <- dbtools::get_athena_query_response("SELECT * from crest_v1.flatfile limit 10000")

# print out path to athena query output (as a csv)
print(response$s3_path)

# print out meta data
print(response$meta)

# Read in data using whatever csv reader you want (in this example using data.table::fread but reading everything as a string)
s3_path_stripped = gsub("s3://", "", response$s3_path)
df <- s3tools::read_using(FUN = data.table::fread, s3_path=s3_path_stripped)
```

## Meta data conformance

When using the `read_sql` function you can specify the type of dataframe to return:

- tibble _(default)_
- data.table
- dataframe

_note: to find out more on this function see the function documentation i.e. `?dbtools::read_sql`_

Each is a type of dataframe in R and have different quirks when converting from Athena datatypes to R datatypes.

- *tibble:* This is the default dataframe choice as it was the only dataframe that converts dates and datetimes (aka timestamps) on read rather than requiring a second parse of the data to convert date and timestamps to their correct types from strings. This is a good option if your data is not that large and you like those tidyverse things. One downside is that long integers are actually stored as doubles (this is because tibbles currently don't support 64 bit integers - [see issue](https://github.com/tidyverse/readr/issues/633)).

- *data.table:* This dataframe class is really good for larger datasets (as it's more memory efficient and just generally better). long integers are read in as int64. Dates and datetimes are read in as strings. Feel free to cast the columns afterwards, `data.table::fread` doesn't convert them on read - [see documentation](https://www.rdocumentation.org/packages/data.table/versions/1.10.4-2/topics/fread).

- *dataframe:* Added support for this because it's the base dataframe type in R. However, Athena exports CSVs with every value in double quotes because of this the `scan` function that is called internally by `read.csv` throws an error unless you specify columns as a character ([see issue](https://stackoverflow.com/questions/35605354/r-read-numeric-values-wrapped-in-quotes-from-csv)). Therefore the returning dataframe has every column type as a character. Feel free to cast the columns afterwards.

## Meta data conversion

Below is a table that explains what the conversion is from our data types to the supported dataframe in R (using the read_sql function):

| data type | tibble type _(R atomic type)_        | data.table type _(R atomic type)_ | dataframe type _(R atomic type)_ |
|-----------|--------------------------------------|-----------------------------------|----------------------------------|
| character | readr::col_character() _(character)_ | character                         | character                        |
| int       | readr::col_integer() _(integer)_     | integer                           | character                        |
| long      | readr::col_double() _(double)_       | bit64::integer64() _(double)_     | character                        |
| date      | readr::col_date() _(double)_         | character                         | character                        |
| datetime  | readr::col_datetime() _(double)_     | character                         | character                        |
| boolean   | readr::col_logical() _(logical)_     | logical                           | character                        |
| float     | readr::col_double() _(double)_       | double                            | character                        |
| double    | readr::col_double() _(double)_       | double                            | character                        |

_Note: If the R atomic type is not listed in the table above then it is the same as the type specified_

#### Meta data

The output from dbtools::get_athena_query_response(...) is a list one of its keys is `meta`. The meta key is a list where each element in this list is the name (`name`) and data type (`type`) for each column in your athena query output. For example for this table output:

|col1|col2|
|---|---|
|1|2018-01-01|
|2|2018-01-02|
...

Would have a meta like:

```
response$meta[[1]]$name # col1
response$meta[[1]]$type # int

response$meta[[1]]$name # col2
response$meta[[1]]$type # date

```

The meta types follow those listed as the generic meta data types used in [etl_manager](https://github.com/moj-analytical-services/etl_manager). If you want the actual athena meta data instead you can get them instead of the generic meta data types by setting the `return_athena_types` input parameter to `TRUE` e.g.

```
response <- dbtools::get_athena_query_response("SELECT * from crest_v1.flatfile limit 10000", return_athena_types=TRUE)

print(response$meta)
```

#### Notes:

- Amazon Athena using a flavour of SQL called presto docs can be found [here](https://prestodb.io/docs/current/)
- To query a date column in Athena you need to specify that your value is a date e.g. `SELECT * FROM db.table WHERE date_col > date '2018-12-31'`
- To query a datetime or timestamp column in Athena you need to specify that your value is a timestamp e.g. `SELECT * FROM db.table WHERE datetime_col > timestamp '2018-12-31 23:59:59'`
- Note dates and datetimes formatting used above. See more specifics around date and datetimes [here](https://prestodb.io/docs/current/functions/datetime.html)
- To specify a string in the sql query always use '' not "". Using ""'s means that you are referencing a database, table or col, etc.
- When data is pulled back into rStudio the column types are either R characters (for any col that was a dates, datetimes, characters) or doubles (for everything else).

#### Under The Hood

When you run a query in SQL against our databases you are using Athena. When Athena produces the output of an SQL query it is always written to a location in S3 as a csv. dbtools defines the S3 location based on your AWS role. It will write the output CSV into a folder only you have read/write access to, and then read it in using `s3tools`. Once the data has been read into a dataframe dbtools will delete the CSV from your folder.

**Note:** dbtools requires you to have the StandardDatabaseAccess group policy attached. If you want to use dbtools please ask the data engineering team (on slack ideally via the #analytical_platform channel). 

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
