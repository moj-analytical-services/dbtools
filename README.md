# dbtools

This is a simple package that let's you query databases using Amazon Athena and get the s3 path to the athena out (as a csv). This is significantly faster than using the the database drivers so might be a good option when pulling in large data.

To install
```r
devtools::install_github('moj-analytical-services/dbtools')
```

package requirements are:

- `s3tools` _(preinstalled)_
- `reticulate`
- `boto3` _(preinstalled)_
- `python` _(preinstalled)_

optional requirements:
- `readr` _(preinstalled)_
- `data.table`

Example:
```r
response <- dbtools::get_athena_query_response("SELECT * from crest_v1.flatfile limit 10000", out_path = "s3://my-bucket/__temp__")

# print out path to athena query output (as a csv)
print(response$s3_path)

# print out meta data
print(response$s3_path)

# Read in data using whatever csv reader you want
s3_path_stripped = gsub("s3://", "", response$s3_path)
df <- s3tools::read_using(FUN = readr::read_csv, s3_path=s3_path_stripped)

```
## Meta data conformance

When using the `read_sql` function you are required to specify the type of dataframe to return:

- tibble _(default)_
- data.table
- dataframe

_note: to find out more on this function see the function documentation i.e. `?dbtools::read_sql`_

Each is a type of dataframe in R and have different querks when converting from Athena datatypes to R datatypes.

- *tibble:* This is the default dataframe choice as it was the only dataframe that converts dates and datetimes (aka timestamps) on read rather than requiring a second parse of the data to convert date and timestamps to their correct types from strings. This is a good option if your data is not that large and you like those tidyverse things. One downside is that long integers are actually stored as doubles (this is because tibbles currently don't support 64 bit integers - [see issue](https://github.com/tidyverse/readr/issues/633)).

- *data.table:* This dataframe class is really good for larger datasets (as it's more memory efficient and just generally better). long integers are read in as int64. Dates and datetimes are read in as strings. Feel free to cast the columns afterwards, `data.table::fread` doesn't convert them on read - [see documentation](https://www.rdocumentation.org/packages/data.table/versions/1.10.4-2/topics/fread).

- *dataframe:* Added support for this because it's the base dataframe type in R. Dates/datetimes are read in as strings and long integers (64 bit) are read in as doubles. Feel free to cast the columns afterwards. `read.csv` doesn't convert them on read in so will leave any further datatype conversion to the user (for the time being at least, if you're so inclinded pull requests are always welcome).

## Meta data conversion

Below is a table that explains what the conversion is from our data types to the supported dataframe in R (using the read_sql function):

| data type | tibble type _(R atomic type)_        | dataframe type _(R atomic type)_ | data.table type _(R atomic type)_ |
|-----------|--------------------------------------|----------------------------------|-----------------------------------|
| character | readr::col_character() _(character)_ | character                        | character                         |
| int       | readr::col_integer() _(integer)_     | integer                          | bit64::integer64() _(?)_          |
| long      | readr::col_double() _(double)_       | double                           | double                            |
| date      | readr::col_date() _(double)_         | character                        | character                         |
| datetime  | readr::col_datetime() _(double)_     | character                        | character                         |
| boolean   | readr::col_logical() _(logical)_     | logical                          | logical                           |
| float     | readr::col_double() _(double)_       | double                           | double                            |
| double    | readr::col_double() _(double)_       | double                           | double                            |

#### Meta data

The output from dbtools::get_athena_query_response(...) is a list one of it's keys is `meta`. The meta key is a list where each element in this list is the name (`name`) and data type (`type`) for each column in your athena query output. For example for this table output:

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


#### Changelog:

## v0.0.2 - 2018-10-12

- `timeout` is now an input parameter to `get_athena_query_response` if not set there is no timeout for the athena query.
- `get_athena_query_response` will now print out the athena_client response if the athena query fails.

## v0.0.1 - First Release
