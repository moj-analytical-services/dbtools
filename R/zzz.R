dbtools.env <- new.env(parent=emptyenv())
.onLoad <- function(libname, pkgname) {
  # import Python package on package load
  assign('pydb', reticulate::import('pydbtools'), dbtools.env)
}
