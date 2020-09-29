.onLoad <- function(libname, pkgname) {
  # Construct Python path and pass it to reticulate
  base_path <- strsplit(Sys.getenv("PATH"), ":")[[1]][1]
  python_path <- paste(base_path, "/python", sep = "")
  reticulate::use_python(python_path)
}
