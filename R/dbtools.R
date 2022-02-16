#' dbtools: A package for accessing AWS Athena from the Analytical Platform.
#'
#' @section About:
#' The dbtools package is used to run SQL queries configured for the
#' Analytical Platform. This package is a reticulated
#' wrapper around the Python library pydbtools
#' which uses AWS Wrangler's Athena module but adds additional functionality
#' (like Jinja templating, creating temporary tables) and alters some configuration
#' to our specification.
#'
#' Alternatively you might want to use
#' Rdbtools, which has the
#' advantages of being R-native, so no messing with `reticulate` and Python, and
#' supporting `dbplyr`. Please note the caveat about support, though.
#'
#' @seealso \url{https://github.com/moj-analytical-services/pydbtools}
#' @seealso \url{https://github.com/moj-analytical-services/Rdbtools}
#'
#' @docType package
#' @name dbtools
NULL
#> NULL
