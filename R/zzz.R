.onLoad <- function(libname, pkgname) {
  if(!reticulate::py_module_available("pydbtools")) {
    reticulate::conda_install(envname = "rstudio", packages = "pydbtools==2.0.0", pip = TRUE)
  }
}
