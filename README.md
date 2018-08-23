# dbtools

This is a simple package that let's you query databases using Amazon Athena.

To install
```r
devtools::install_github('moj-analytical-services/dbtools')
```

Example:
```r
con <- dbtools::get_athena_connection(bucket)
data <- RJDBC::dbGetQuery(con, 'SELECT * FROM crest_v1.flatfile limit 1000')

View(data)
```

#### Notes: 

- Amazon Athena using a flavour of SQL called presto docs can be found [here](https://prestodb.io/docs/current/)
- To query a date column in Athena you need to specify that your value is a date e.g. `SELECT * FROM db.table WHERE date_col > date '2018-12-31'`
- To query a datetime or timestamp column in Athena you need to specify that your value is a timestamp e.g. `SELECT * FROM db.table WHERE datetime_col > timestamp '2018-12-31 23:59:59'`
- Note dates and datetimes formatting used above. See more specifics around date and datetimes [here](https://prestodb.io/docs/current/functions/datetime.html)
- To specify a string in the sql query always use '' not "". Using ""'s means that you are referencing a database, table or col, etc.
