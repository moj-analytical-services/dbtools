context("Test data reads in with correct meta data")

test_that("Test read_sql", {

  tib <- dbtools::read_sql("SELECT * from dbtools.test_data", 'dbtools-test-bucket', return_df_as='tibble')
  df <- dbtools::read_sql("SELECT * from dbtools.test_data", 'dbtools-test-bucket', return_df_as='dataframe')
  dt <- dbtools::read_sql("SELECT * from dbtools.test_data", 'dbtools-test-bucket', return_df_as='data.table')

})
