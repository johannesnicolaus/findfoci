#' Shiny-based visualization of single-cell foci number across time
#'
#' @return
#' @export
#'
#' @examples heatscatter()
heatscatter <- function() {
  appDir <- system.file("visualization", "app", package = "findfoci")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `Find foci`.", call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal")
}
