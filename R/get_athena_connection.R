#' get_athena_connection
#'
#'@description establishes a connection to the databases on AWS allowing users to query the data with SQL
#'
#'@import RJDBC
#'
#'@export
#'
#'@details Returns a connection to all the databases stored on AWS. You make be able to see all the database but you may not be able to query them depending on what permissions
#' you have to S3 buckets. If you get an access denied error when trying to query a database please contact the owner of the bucket in which the data exists and ask for access to the
#' data.
#'
#'@return A connection to the databases on AWS
#'
#'@examples
#'# Get the connection to the crest data and then query crest using get_athena_connection
#'
#'bucket <- alpha-dag-crest-data-engineering
#'con <- get_athena_connection(bucket)
#'data <- RJDBC::dbGetQuery(con, 'SELECT * FROM crest_v1.flatfile limit 1000')
get_athena_connection <- function(){

  athena_out <- 's3://aws-athena-query-results-593291632749-eu-west-1'
  
  # Downloads for now but should add to standard docker deployment for rStudio
  URL <- 'https://s3.amazonaws.com/athena-downloads/drivers/JDBC/SimbaAthenaJDBC_2.0.5/AthenaJDBC42_2.0.5.jar'
  fil <- paste0('~/', basename(URL))
  if (!file.exists(fil)) download.file(URL, fil)

  drv <- RJDBC::JDBC(driverClass="com.simba.athena.jdbc.Driver", fil, identifier.quote="'")

  provider <- "com.simba.athena.amazonaws.auth.InstanceProfileCredentialsProvider"

  con <- RJDBC::dbConnect(drv, 'jdbc:awsathena://athena.eu-west-1.amazonaws.com:443',
                          s3_staging_dir=athena_out,
                          aws_credentials_provider_class=provider)

  return(con)
}


