dbtools.env <- new.env(parent=emptyenv())
.onLoad <- function(libname, pkgname) {
  # import Python packages on package load
  boto3 <- reticulate::import('boto3')
  assign('pydb', reticulate::import('pydbtools'), dbtools.env)
  assign('athena_client', boto3$client('athena'), dbtools.env)
}
