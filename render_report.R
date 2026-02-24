#' Render report.Rmd to a configurable output directory as index.html.
#'
#' Output directory (in order of precedence):
#' 1. STATIC_OUTPUT_DIR environment variable (e.g. /Volumes/... in Databricks)
#' 2. First command-line argument
#' 3. Default: "static" (relative to current working directory)
#'
#' Use from RStudio or a Databricks notebook: set working directory to the
#' project root, then source("render_report.R") or render_report("/path/to/out").
#'
#' @param out_dir Optional output directory. If NULL, uses env or default.
#' @return Invisible path to the rendered index.html.
render_report <- function(out_dir = NULL) {
  if (!requireNamespace("rmarkdown", quietly = TRUE)) {
    stop("Install rmarkdown: install.packages(\"rmarkdown\")")
  }
  args <- commandArgs(trailingOnly = TRUE)
  out_dir <- out_dir %||% if (length(args) > 0L) args[1L] else NULL
  out_dir <- out_dir %||% Sys.getenv("STATIC_OUTPUT_DIR", "") %||% "static"
  if (out_dir == "") out_dir <- "static"
  out_dir <- normalizePath(out_dir, mustWork = FALSE)
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
  input_file <- "report.Rmd"
  if (!file.exists(input_file)) {
    stop("report.Rmd not found. Set working directory to the project root.")
  }
  rmarkdown::render(
    input = input_file,
    output_file = "index.html",
    output_dir = out_dir,
    quiet = FALSE
  )
  invisible(file.path(out_dir, "index.html"))
}

# Simple %||% helper (works when rlang not installed)
`%||%` <- function(x, y) if (length(x) > 0L && !is.na(x) && nzchar(x)) x else y

# When script is run via Rscript or source()d (e.g. in Databricks notebook), render.
# Skip only when the file is being sourced by another file that needs render_report().
if (!identical(Sys.getenv("RENDER_REPORT_SKIP"), "true")) {
  render_report()
}
