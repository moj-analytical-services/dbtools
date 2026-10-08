dbtools.env <- new.env(parent=emptyenv())
.onLoad <- function(libname, pkgname) {
  packageStartupMessage('dbtools is no longer maintained. Please migrate to Rdbtools: https://github.com/moj-analytical-services/Rdbtools')
  # import Python package on package load
  assign('pydb', reticulate::import('pydbtools'), dbtools.env)
}
