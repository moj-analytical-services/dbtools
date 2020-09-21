.onLoad <- function(libname, pkgname) {
  reticulate::use_python(".conda/envs/rstudio/bin/python")
  if(!reticulate::py_module_available("pydbtools")) {
    reticulate::conda_install(envname = "rstudio", packages = "pydbtools==2.0.0", pip = TRUE)
  }
}
