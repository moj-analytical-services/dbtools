.onLoad <- function(libname, pkgname) {
  if(!reticulate::py_module_available("pydbtools")) {
    reticulate::conda_install(packages = "pydbtools", pip = TRUE)
  }
}
