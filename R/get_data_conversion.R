get_data_conversion <- function(function_name){
    
  if(function_name == 'tibble'){
    conversion <- list(
      "character" = readr::col_character(),
      "int" = readr::col_integer(),
      "long" = readr::col_integer(),
      "date" = readr::col_date(),
      "datetime" = readr::col_datetime(),
      "boolean" = readr::col_logical(),
      "float" = readr::col_double(),
      "double" = readr::col_double()
    )
  } else if("data.table"){
    conversion <- NULL
    print('NOT SUPPORTED YET  ¯\_(ツ)_/¯')
  } else {
    conversion <- NULL
    print('NOT SUPPORTED YET  ¯\_(ツ)_/¯')
  }
  return(conversion)
}