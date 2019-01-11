context("Test data reads in with correct meta data")

test_that("data from read_sql as tibble conforms", {

  # Test all cols read
  df <- dbtools::read_sql("SELECT * from dbtools.test_data", 'alpha-dbtools-test-bucket', return_df_as='tibble')
  t1 <- all(colnames(df) == c("character_col","int_col","long_col","date_col","datetime_col","boolean_col","float_col","double_col"))
  expect_true(t1)

  # Test all rows read
  t2 <- length(df) == 8
  expect_true(t2)

  # Test col types
  type_vec <- c()
  class_vec <- c()
  for (c in colnames(df)){
    type_vec <- c(type_vec, typeof(df[[c]]))
    class_vec <- c(class_vec, paste(class(df[[c]]), collapse = ' '))
  }

  t3 <- all(type_vec ==  c("character","integer","integer","double","double","logical","double","double"))
  t4 <- all(class_vec == c("character","integer","integer","Date","POSIXct POSIXt","logical","numeric","numeric"))
  expect_true(t3)
  expect_true(t4)



})


test_that("data from read_sql as data.table conforms", {

  #### DEBUG ####
  # return_df_as='data.table'
  # bucket='alpha-dbtools-test-bucket'
  # sql_query="SELECT * from dbtools.test_data"
  # timeout = NULL
  # output_folder="__athena_temp__/"

  # Test all cols read
  df <- dbtools::read_sql("SELECT * from dbtools.test_data", 'alpha-dbtools-test-bucket', return_df_as='data.table')
  t1 <- all(colnames(df) == c("character_col","int_col","long_col","date_col","datetime_col","boolean_col","float_col","double_col"))
  expect_true(t1)

  # Test all rows read
  t2 <- length(df) == 8
  expect_true(t2)

  # Test col types
  type_vec <- c()
  class_vec <- c()
  for (c in colnames(df)){
    type_vec <- c(type_vec, typeof(df[[c]]))
    class_vec <- c(class_vec, paste(class(df[[c]]), collapse = ' '))
  }

  t3 <- all(type_vec ==  c("character","integer","integer","double","double","logical","double","double"))
  t4 <- all(class_vec == c("character","integer","integer","Date","POSIXct POSIXt","logical","numeric","numeric"))
  expect_true(t3)
  expect_true(t4)

})
