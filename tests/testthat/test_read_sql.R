context("Test data reads in with correct meta data")

test_that("data from read_sql conforms", {

  tib <- dbtools::read_sql("SELECT * from dbtools.test_data", 'dbtools-test-bucket', return_df_as='tibble')
  names(tib)

  df <- dbtools::read_sql("SELECT * from dbtools.test_data", 'dbtools-test-bucket', return_df_as='dataframe')
  dt <- dbtools::read_sql("SELECT * from dbtools.test_data", 'dbtools-test-bucket', return_df_as='data.table')

})
