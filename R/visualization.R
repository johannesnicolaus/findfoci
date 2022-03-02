#' Heatscatter
#'
#' @return
#' @export
#'
#' @examples
heatscatter <- function() {
  appDir <- system.file("visualization", "app", package = "Findfoci")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `Find foci`.", call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal")
}
