.onLoad <- function(libname, pkgname) {
  if(!reticulate::py_module_available("pydbtools")) {
    reticulate::conda_install(envname = "rstudio", packages = "pydbtools", pip = TRUE)
  }
}
