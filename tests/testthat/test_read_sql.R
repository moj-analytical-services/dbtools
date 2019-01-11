context("Test data reads in with correct meta data")

### ### ### ### ### ### ###
###       tibble        ###
### ### ### ### ### ### ###
test_that("data from read_sql as tibble conforms", {

  # Test all cols read
  df <- dbtools::read_sql("SELECT * from dbtools.test_data", 'alpha-dbtools-test-bucket', return_df_as='tibble')

  expect_equal(colnames(df), c("character_col","int_col","long_col","date_col","datetime_col","boolean_col","float_col","double_col"))

  # Test all rows read
  expect_true(length(df) == 8)

  # Test col types
  type_vec <- c()
  class_vec <- c()
  for (c in colnames(df)){
    type_vec <- c(type_vec, typeof(df[[c]]))
    class_vec <- c(class_vec, paste(class(df[[c]]), collapse = ' '))
  }

  expect_equal(type_vec, c("character","integer","integer","double","double","logical","double","double"))
  expect_equal(class_vec, c("character","integer","integer","Date","POSIXct POSIXt","logical","numeric","numeric"))

  first_row <- c(df[[1,1]])
  second_row <- c(df[[2,1]])

  for(i in 2:8){
    first_row <- c(first_row, as.character(df[[1,i]]))
    second_row <- c(second_row, as.character(df[[2,i]]))
  }
  exp_first_row <- c("malcovitch", "1", "2147483648","1900-01-01","1900-01-01","TRUE","0.123456","0.123456789")
  exp_second_row <- c("malcovitch, malcovitch","2147483647","1e+10","2018-01-01","2018-01-01 23:59:59","FALSE","3.141592","3.141592653589")

  expect_equal(first_row, exp_first_row)
  expect_equal(second_row, exp_second_row)
})


### ### ### ### ### ### ###
###     data.table      ###
### ### ### ### ### ### ###
test_that("data from read_sql as data.table conforms", {

  # Test all cols read
  df <- dbtools::read_sql("SELECT * from dbtools.test_data", 'alpha-dbtools-test-bucket', return_df_as='data.table')
  expect_equal(colnames(df), c("character_col","int_col","long_col","date_col","datetime_col","boolean_col","float_col","double_col"))

  # Test all rows read
  expect_true(length(df) == 8)

  # Test col types
  type_vec <- c()
  class_vec <- c()
  for (c in colnames(df)){
    type_vec <- c(type_vec, typeof(df[[c]]))
    class_vec <- c(class_vec, paste(class(df[[c]]), collapse = ' '))
  }

  expect_equal(type_vec, c("character","integer","double","character","character","logical","double","double"))
  expect_equal(class_vec, c("character","integer","integer64","character","character","logical","numeric","numeric"))

  first_row <- c(df[[1,1]])
  second_row <- c(df[[2,1]])

  for(i in 2:8){
    first_row <- c(first_row, as.character(df[[1,i]]))
    second_row <- c(second_row, as.character(df[[2,i]]))
  }
  exp_first_row <- c("malcovitch", "1", "2147483648","1900-01-01","1900-01-01 00:00:00.000","TRUE","0.123456","0.123456789")
  exp_second_row <- c("malcovitch, malcovitch","2147483647","10000000000","2018-01-01","2018-01-01 23:59:59.000","FALSE","3.141592","3.141592653589")

  expect_equal(first_row, exp_first_row)
  expect_equal(second_row, exp_second_row)

})


### ### ### ### ### ### ###
###      dataframe      ###
### ### ### ### ### ### ###
test_that("data from read_sql as dataframe conforms", {

  # Test all cols read
  df <- dbtools::read_sql("SELECT * from dbtools.test_data", 'alpha-dbtools-test-bucket', return_df_as='dataframe')
  expect_equal(colnames(df), c("character_col","int_col","long_col","date_col","datetime_col","boolean_col","float_col","double_col"))

  # Test all rows read
  expect_true(length(df) == 8)

  # Test col types
  type_vec <- c()
  class_vec <- c()
  for (c in colnames(df)){
    type_vec <- c(type_vec, typeof(df[[c]]))
    class_vec <- c(class_vec, paste(class(df[[c]]), collapse = ' '))
  }

  expect_equal(type_vec, c("character","character","character","character","character","character","character","character"))
  expect_equal(class_vec, c("character","character","character","character","character","character","character","character"))

  first_row <- c(df[[1,1]])
  second_row <- c(df[[2,1]])

  for(i in 2:8){
    first_row <- c(first_row, as.character(df[[1,i]]))
    second_row <- c(second_row, as.character(df[[2,i]]))
  }
  exp_first_row <- c("malcovitch", "1", "2147483648","1900-01-01","1900-01-01 00:00:00.000","TRUE","0.123456","0.123456789")
  exp_second_row <- c("malcovitch, malcovitch","2147483647","10000000000","2018-01-01","2018-01-01 23:59:59.000","FALSE","3.141592","3.141592653589")

  expect_equal(first_row, exp_first_row)
  expect_equal(second_row, exp_second_row)

})

