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
#'@param bucket A string specifying the bucket you want to throw your athena queries to.
#'This must be a bucket you have read-write access to. Ideally make this the bucket where the data you are querying is stored.
#'When you run your athena queries the outputs will be stored in s3://bucket/athena_temp_outputs/.
#'
#'@return A connection to the databases on AWS
#'
#'@examples
#'# Get the connection to the crest data and then query crest using get_athena_connection
#'
#'bucket <- alpha-dag-crest-data-engineering
#'con <- get_athena_connection(bucket)
#'data <- RJDBC::dbGetQuery(con, 'SELECT * FROM crest_v1.flatfile limit 1000')
get_athena_connection <- function(bucket){

  athena_out <- paste0('s3://',bucket,'/athena_temp_dir/')
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


