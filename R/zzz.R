.onLoad <- function(libname, pkgname) {
  # Construct Python path and pass it to reticulate
  base_path <- strsplit(Sys.getenv("PATH"), ":")[[1]][1]
  python_path <- paste(base_path, "/python", sep = "")
  reticulate::use_python(python_path)

  # Check if pydbtools is installed. If it isn't, install it through Conda
  if(!reticulate::py_module_available("pydbtools")) {
    reticulate::conda_install(envname = "rstudio", packages = "pydbtools==2.0.1", pip = TRUE)
  }
}
