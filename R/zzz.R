.onLoad <- function(libname, pkgname) {
  base_path = strsplit(Sys.getenv("PATH"), ":")[[1]][1]
  python_bath = paste(base_path, "/python", sep = "")
  reticulate::use_python(python_path)
  if(!reticulate::py_module_available("pydbtools")) {
    reticulate::conda_install(envname = "rstudio", packages = "pydbtools==2.0.1", pip = TRUE)
  }
}
