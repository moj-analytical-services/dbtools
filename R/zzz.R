dbtools.env <- new.env(parent=emptyenv())
.onLoad <- function(libname, pkgname) {
  packageStartupMessage('dbtools is no longer maintained. Please migrate to rdbtools: https://github.com/moj-analytical-services/rdbtools')
  # import Python package on package load
  assign('pydb', reticulate::import('pydbtools'), dbtools.env)
}
