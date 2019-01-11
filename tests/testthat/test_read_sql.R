context("Test data reads in with correct meta data")

test_that("data from read_sql as tibble conforms", {

  # Test all cols read
  tib <- dbtools::read_sql("SELECT * from dbtools.test_data", 'alpha-dbtools-test-bucket', return_df_as='tibble')
  t1 <- all(colnames(tib) == c("character_col","int_col","long_col","date_col","datetime_col","boolean_col","float_col","double_col"))
  expect_true(t1)

  # Test all rows read
  t2 <- length(tib) == 8
  expect_true(t2)

  # Test col types
  type_vec <- c()
  class_vec <- c()
  for (c in colnames(tib)){
    type_vec <- c(type_vec, typeof(tib[[c]]))
    class_vec <- c(class_vec, paste(class(tib[[c]]), collapse = ' '))
  }

  t3 <- all(type_vec ==  c("character","integer","integer","double","double","logical","double","double"))
  t4 <- all(class_vec == c("character","integer","integer","Date","POSIXct POSIXt","logical","numeric","numeric"))
  expect_true(t3)
  expect_true(t4)

  # Test col types
  df <- dbtools::read_sql("SELECT * from dbtools.test_data", 'dbtools-test-bucket', return_df_as='dataframe')
  dt <- dbtools::read_sql("SELECT * from dbtools.test_data", 'dbtools-test-bucket', return_df_as='data.table')

})
