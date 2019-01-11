get_data_conversion <- function(df_type){

  if(df_type == 'tibble'){
    # Note how 64 bit integers (long) are read in as double
    conversion <- list(
      "character" = readr::col_character(),
      "int" = readr::col_integer(),
      "long" = readr::col_double(),
      "date" = readr::col_date(),
      "datetime" = readr::col_datetime(),
      "boolean" = readr::col_logical(),
      "float" = readr::col_double(),
      "double" = readr::col_double()
    )
  } else if(df_type == 'data.table'){
    # Note that dates/datetimes are read in as characters
    conversion <- list(
      "character" = "character",
      "int" = "integer",
      "long" = "integer64",
      "date" = "character",
      "datetime" = "character",
      "boolean" = "logical",
      "float" = "double",
      "double" = "double"
    )
  } else {
    # have to read in everything as character see readme
    conversion <- list(
      "character" = "character",
      "int" = "character",
      "long" = "character",
      "date" = "character",
      "datetime" = "character",
      "boolean" = "character",
      "float" = "character",
      "double" = "character"
    )
  }
  return(conversion)
}
